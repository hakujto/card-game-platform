#!/usr/bin/env python
"""
One-shot setup: create venv, install deps, start uvicorn.
Usage: python setup.py
"""
import os
import subprocess
import sys
import venv

BASE = os.path.dirname(os.path.abspath(__file__))
VENV = os.path.join(BASE, "venv")

# 1. create venv if needed
if not os.path.exists(VENV):
    print("==> Creating virtual environment...")
    venv.create(VENV, with_pip=True)

# resolve the venv python/pip executables
if sys.platform == "win32":
    venv_python = os.path.join(VENV, "Scripts", "python.exe")
else:
    venv_python = os.path.join(VENV, "bin", "python")

# 2. install dependencies inside the venv
print("==> Installing dependencies...")
subprocess.check_call([venv_python, "-m", "pip", "install", "--quiet", "-r",
                       os.path.join(BASE, "requirements.txt")])

# 3. start server
print("")
print("==> Starting server...")
print("    API:   http://localhost:8000/api/")
print("    Docs:  http://localhost:8000/docs")
print("")
os.execv(venv_python, [venv_python, "-m", "uvicorn", "app.main:app",
                        "--reload", "--host", "0.0.0.0", "--port", "8000"])
