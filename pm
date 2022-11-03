#!/usr/bin/python3

import json
import sys
import os
import subprocess
import re

CUR_PM_VERS = 1

def pm_add(conf_path, db, args):

   name = args[0]
   path = args[1]
   projects = db.get('projects')
      
   if name in projects:
      print("Project already exists")
   else:
      projects[name] = {"path": path}
      
      try:
         with open(conf_path, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         print("Added project")
      except FileNotFoundError:
         print("WARN: Unable to save projects db")
         

def pm_ls(conf_path, db, args):
   projects = db.get('projects')
   for k,v in projects.items():
      print(f"{k}:{(20-len(k))*' '} -> {v['path']}")


def pm_rm(conf_path, db, args):
   
   name = args[0]
   projects = db.get('projects')
   
   if name in projects.keys():
      projects.pop(name)
      
      try:
         with open(conf_path, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         print("Removed project")
      except FileNotFoundError:
         print("WARN: Unable to save projects db")
         
   else:
      print("Project not in db")


def pm_chdir(conf_path, db, args):
   
   name = args[0]
   path = args[1]
   projects = db.get('projects')
   
   if name in projects.keys():
      projects[name]["path"] = path
      
      try:
         with open(conf_path, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         print("Updated project")
      except FileNotFoundError:
         print("WARN: Unable to save projects db")
         
   else:
      print("Project not in db")
         

def pm_rename(conf_path, db, args):
      
   old_name = args[0]
   new_name = args[1]
   projects = db.get('projects')
         
   if old_name in projects.keys():
      proj_data = projects[old_name]
      projects.pop(old_name)
      projects[new_name] = proj_data
      
      try:
         with open(conf_path, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         print("Renamed project")
      except FileNotFoundError:
         print("WARN: Unable to save projects db")
            
   else:
      print("Project not in db")

def pm_help(conf_path, db, args):

   print("Ray's Project Manager 2022 v1.0")
   print("USAGE:")
   print("$ pm <sub-command|project-name> [args]")
   print()
   print("SUB COMMANDS:")
   for v in SUBCMDS.values():
      print(f"  {v['desc']}")
      

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
      print("Expected sub command or project")
      exit(1)

   home = os.environ.get('HOME')
   if not home:
      print("ERROR: $HOME not set")
      exit(-1)

   conf_path = f"{home}/.config/proj/projects.json"
      
   db = {}
   try:
      with open(conf_path, "r") as fp:
         db = json.load(fp)
      print("INFO: loaded projects db")
   except FileNotFoundError:
      print("WARN: Unable to find projects db")
      db = {'pm_ver': CUR_PM_VERS, 'term': [], 'projects': {}}
      try:
         with open(conf_path, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         print("Created new projects db")
      except FileNotFoundError:
         print("WARN: Unable to save projects db")
   except json.decoder.JSONDecodeError:
      print("ERROR: Malformed projects db, exiting")
      print(f"DEBUG: db location: '{conf_path}'")
      exit(-1)
      
   if db.get('projects') == None:
      print("WARN: projects dict missing")
      print(projects)
      db['projects'] = {}

   if CUR_PM_VERS != db.get('pm_ver'):
      print("WARN: Using project config from older PM version")
         
   if argv[0] in SUBCMDS:
      subargs = argv[1:]
      subcmd = SUBCMDS[argv[0]]
      if subcmd["argc"] != len(subargs):
         print(f"ERROR: Sub command exprected {subcmd['argc']} args but got {len(subargs)}")
      else:
         subcmd["func"](conf_path, db, argv[1:])
      exit(0)
         
   else:
      term = db.get('term')
      projects = db.get('projects')
      if argv[0] in projects.keys():
         p = projects.get(argv[0])
         name = argv[0]
         path = p.get('path')
         if not term:
            print("ERROR: terminal setting missing from config")
         else:
            print(f"Opening '{name}' @ '{path}'")
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
                  subprocess.call(subproc, shell=False)
               except FileNotFoundError:
                  print("ERROR: unable to start terminal - command not found")
            else:
               print("ERROR: Missing value for terminal in config")

      else:
         print("Unable to find project")

      exit(0)
         




   
