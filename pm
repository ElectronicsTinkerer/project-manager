#!/usr/bin/python3

import json
import sys
import os
import subprocess
import re

# Config version
CUR_PM_VERS = 3

DEBUG = -1
INFO = 0
WARN = 1
ERROR = 2
MSG_LEVELS = [
   "DEBUG",
   "INFO",
   "WARN",
   "ERROR"
]

def pm_add(db_path, db, conf, args):

   name = args[0]
   path = args[1]
   projects = db.get('projects')
      
   if name in projects:
      return msg(f"Project '{name}' already exists", WARN, conf)
   else:
      projects[name] = {"path": path}
      
      try:
         with open(db_path, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         return msg(f"Added project '{name}'", INFO, conf)
      except FileNotFoundError:
         return msg("Unable to save projects db", ERROR, conf)
         

def pm_ls(db_path, db, conf, args):
   projects = db.get('projects')
   for k,v in projects.items():
      print(f"{k}:{(20-len(k))*' '} -> {v['path']}")


def pm_rm(db_path, db, conf, args):
   
   name = args[0]
   projects = db.get('projects')
   
   if name in projects.keys():
      projects.pop(name)
      
      try:
         with open(db_path, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         return msg(f"Removed project '{name}'", INFO, conf)
      except FileNotFoundError:
         return msg("Unable to save projects db", ERROR, conf)
         
   else:
      return msg(f"Project '{name}' not in db", WARN, conf)


def pm_chdir(db_path, db, conf, args):
   
   name = args[0]
   path = args[1]
   projects = db.get('projects')
   
   if name in projects.keys():
      projects[name]["path"] = path
      
      try:
         with open(db_path, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         return msg(f"Updated project '{name}'", INFO, conf)
      except FileNotFoundError:
         return msg("Unable to save projects db", ERROR, conf)
         
   else:
      return msg(f"Project '{name}' not in db", WARN, conf)
         

def pm_rename(db_path, db, conf, args):
      
   old_name = args[0]
   new_name = args[1]
   projects = db.get('projects')
         
   if old_name in projects.keys():
      proj_data = projects[old_name]
      projects.pop(old_name)
      projects[new_name] = proj_data
      
      try:
         with open(db_path, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         return msg(f"Renamed project '{old_name}' -> '{new_name}'", INFO, conf)
      except FileNotFoundError:
         return msg("Unable to save projects db", ERROR, conf)
            
   else:
      return msg(f"Project '{old_name}' not in db", WARN, conf)


def pm_help(db_path, db, conf, args):

   print("Ray's Project Manager 2026 v1.1")
   print("USAGE:")
   print("$ pm <sub-command|project-name> [args]")
   print()
   print("SUB COMMANDS:")
   for v in SUBCMDS.values():
      print(f"  {v['desc']}")

   return 0
      

def msg(s, lvl, conf):
   
   if lvl > ERROR:
      lvl = ERROR
      
   # Assuming that the msg_level value is an int...
   if (not conf) or (not conf.get("msg_level")) or (lvl >= conf["msg_level"]):
      print(f"{MSG_LEVELS[lvl+1]}: {s}")
      
   return lvl


SUBCMDS = {
   "add": {
      "desc": "add <name> <path> ............. Add a project to the db",
      "func": pm_add,
      "argc": 2
   },
   "ls": {
      "desc": "ls ............................ List all projects in db",
      "func": pm_ls,
      "argc": 0
   },
   "rm": {
      "desc": "rm <name> ..................... Remove project <name>",
      "func": pm_rm,
      "argc": 1
   },
   "chdir": {
      "desc": "chdir <name> <path> ........... Change a project's path",
      "func": pm_chdir,
      "argc": 2
   },
   "rename": {
      "desc": "rename <old-name> <new-name> .. Rename a project",
      "func": pm_rename,
      "argc": 2
   },
   "help": {
      "desc": "help .......................... Display this menu",
      "func": pm_help,
      "argc": 0
   }
}


if __name__ == "__main__":
   argv = sys.argv[1:]

   if len(argv) == 0:
      msg("Expected sub command or project", ERROR, None)
      exit(ERROR)

   home = os.environ.get('HOME')
   if not home:
      msg("$HOME not set", ERROR, None)
      exit(ERROR)

   conf_path = f"{home}/.config/pm/config.json"
   db_path = f"{home}/.config/pm/projects.json"

   conf = {}
   db = {}
   # Load the config
   try:
      with open(conf_path, "r") as fp:
         conf = json.load(fp)
      msg("loaded config", INFO, conf)
   except FileNotFoundError:
      msg("Unable to find config", WARN, None)
      conf = {'pm_ver': CUR_PM_VERS, 'term': [], 'msg_level': INFO}
      try:
         with open(conf_path, "w") as fp:
            json.dump(conf, fp, sort_keys=True)
         msg("Created new config", INFO, conf)
      except FileNotFoundError:
         msg("Unable to save config", WARN, conf)
   except json.decoder.JSONDecodeError:
      msg("Malformed config, exiting", ERROR, None)
      msg(f"config location: '{conf_path}'", DEBUG, None)
      exit(ERROR)

   # Load the projects "db"
   try:
      with open(db_path, "r") as fp:
         db = json.load(fp)
      msg("loaded projects db", INFO, conf)
   except FileNotFoundError:
      msg("Unable to find projects db", WARN, conf)
      db = {'projects': {}}
      try:
         with open(db_path, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         msg("Created new projects db", INFO, conf)
      except FileNotFoundError:
         msg("WARN: Unable to save projects db", ERROR, conf)
         exit(ERROR)
   except json.decoder.JSONDecodeError:
      msg("Malformed projects db, exiting", ERROR, conf)
      msg(f"db location: '{db_path}'", DEBUG, conf)
      exit(ERROR)
      
   if db.get('projects') == None:
      msg("projects dict missing", WARN, conf)
      db['projects'] = {}

   if CUR_PM_VERS != conf.get('pm_ver'):
      msg("Using project config from older PM version", WARN, conf)

   # Check if this is a sub-command first
   if argv[0] in SUBCMDS:
      subargs = argv[1:]
      subcmd = SUBCMDS[argv[0]]
      status = 0
      if subcmd["argc"] != len(subargs):
         msg(f"Sub command expected {subcmd['argc']} args but got {len(subargs)}", ERROR, conf)
         status = ERROR
      else:
         status = subcmd["func"](db_path, db, conf, argv[1:])
      exit(status)

   # If the argument is not a sub-command, it might be a project
   else:
      projects = db.get('projects')
      if argv[0] in projects.keys():
         p = projects.get(argv[0])
         name = argv[0]
         path = p.get('path')
         # Commands to run start with the typical "shebang"
         # otherwise, it's just a project path to chdir to.
         is_command = path.startswith("#!")
         if is_command:
            command = path[2:].strip()
            if len(command) == 0:
               msg(f"No command set for project 'name'", ERROR, conf)
               exit(ERROR)
            else:
               status = 0
               try:
                  msg(f"Running command '{command}'", INFO, conf)
                  subprocess.run(command, shell=True, check=True)
               except subprocess.CalledProcessError as e:
                  msg(f"Command returned non-zero exit status: '{e.returncode}'", ERROR, conf)
                  status = e.returncode
               finally:
                  exit(status)
         else:
            term = conf.get('term')
            if not term:
               msg("Terminal setting missing from config", ERROR, conf)
               exit(ERROR)
            else:
               msg(f"Opening '{name}' @ '{path}'", INFO, conf)
               subproc = []
               for t in term:
                  if t == "TNAME":
                     subproc.append(name)
                  elif t == "TWD":
                     subproc.append(path)
                  else:
                     subproc.append(t)

               if len(subproc) > 0:
                  try:
                     child = subprocess.Popen(subproc, shell=False, start_new_session=True)
                     # child.detach()
                  except FileNotFoundError:
                     msg("Unable to start terminal - command not found", ERROR, conf)
                     exit(ERROR)
               else:
                  msg("Missing value for terminal in config", ERROR, conf)
                  exit(ERROR)

      else:
         msg("Unable to find project", ERROR, conf)
         exit(ERROR)

      exit(0)
   
