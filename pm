#!/usr/bin/python3

import json
import sys
import os
import subprocess
import re

if __name__ == "__main__":
   argv = sys.argv[1:]

   if len(argv) == 0:
      print("Expected operation")
      exit(1)

   home = os.environ.get('HOME')
   if not home:
      print("ERROR: $HOME not set")
      exit(-1)

   home = f"{home}/.config/proj/projects.json"
      
   db = {}
   projects = {}
   try:
      with open(home, "r") as fp:
         db = json.load(fp)
      print("INFO: loaded projects db")
   except FileNotFoundError:
      print("WARN: Could not find projects db")
      db = {'pm_ver': 0, 'projects': {}}
      try:
         with open(home, "w") as fp:
            json.dump(db, fp, sort_keys=True)
         print("Added project")
      except FileNotFoundError:
         print("WARN: Could not save projects db")
   except json.decoder.JSONDecodeError:
      print("ERROR: Malformed projects db, exiting")
      exit(-1)
      
   projects = db.get('projects')
   if projects == None:
      print("WARN: projects dict missing")
      print(projects)
      projects = {}
      db['projects'] = projects
         
   if argv[0] == "add":

      name = argv[1]
      
      if name in projects:
         print("Project already exists")
      else:
         projects[name] = {"path": argv[2]}
      
         try:
            with open(home, "w") as fp:
               json.dump(db, fp, sort_keys=True)
            print("Added project")
         except FileNotFoundError:
            print("WARN: Could not save projects db")

      exit(0)

   elif argv[0] == "ls":
      for k,v in projects.items():
         print(f"{k}:{(20-len(k))*' '} -> {v['path']}")

      exit(0)

   elif argv[0] == "rm":
      
      name = argv[1]
      
      if name in projects.keys():
         projects.pop(name)
      
         try:
            with open(home, "w") as fp:
               json.dump(db, fp, sort_keys=True)
            print("Removed project")
         except FileNotFoundError:
            print("WARN: Could not save projects db")
            
      else:
         print("Project not in db")

      exit(0)


   elif argv[0] == "chdir":
      
      name = argv[1]
      path = argv[2]
      
      if name in projects.keys():
         projects[name]["path"] = path
      
         try:
            with open(home, "w") as fp:
               json.dump(db, fp, sort_keys=True)
            print("Updated project")
         except FileNotFoundError:
            print("WARN: Could not save projects db")
            
      else:
         print("Project not in db")

      exit(0)

   elif argv[0] == "rename":
      
      old_name = argv[1]
      new_name = argv[2]
      
      if old_name in projects.keys():
         proj_data = projects[old_name]
         projects.pop(old_name)
         projects[new_name] = proj_data
      
         try:
            with open(home, "w") as fp:
               json.dump(db, fp, sort_keys=True)
            print("Renamed project")
         except FileNotFoundError:
            print("WARN: Could not save projects db")
            
      else:
         print("Project not in db")

      exit(0)
         
   else:
      if argv[0] in projects.keys():
         p = projects.get(argv[0])
         name = argv[0]
         path = p.get('path')
         print(f"Opening '{name}' @ '{path}'")
         # subprocess.call([
         #    "/usr/bin/gnome-terminal",
         #    "--title", name,
         #    "--working-directory", path,
         #    "--tab"
         # ], shell=False)
         # path = re.sub("/mnt/c", "C:", path)
         subprocess.call([
            "wt.exe",
            "new-tab",
            "--title", name,
            "--startingDirectory", path,
            "wsl"
         ], shell=False)

      else:
         print("Could not find project")

      exit(0)
         




   
