#!/usr/bin/env python
"""
One-shot setup: install deps + migrate + create superuser (admin/admin) + runserver.
"""
import os
import subprocess
import sys

# 0. install dependencies
print("==> Installing dependencies...")
subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])

import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "cards_project.settings")
django.setup()

from django.core.management import call_command

def main():
    # 0. ensure migrations dirs exist (required by makemigrations)
    base = os.path.dirname(os.path.abspath(__file__))
    from django.apps import apps
    for app_config in apps.get_app_configs():
        if app_config.name.startswith('django.') or '.' in app_config.name:
            continue
        mig_dir = os.path.join(base, app_config.name, 'migrations')
        init_file = os.path.join(mig_dir, '__init__.py')
        if not os.path.exists(mig_dir):
            os.makedirs(mig_dir)
            open(init_file, 'w').close()
            print(f"==> Created {app_config.name}/migrations/")

    # 1. migrate
    print("==> Running migrations...")
    call_command("makemigrations")
    call_command("migrate")

    # 2. create superuser if none exists
    from django.contrib.auth import get_user_model
    User = get_user_model()
    if not User.objects.filter(is_superuser=True).exists():
        print("==> Creating superuser: admin / admin")
        User.objects.create_superuser(
            username="admin",
            email="admin@example.com",
            password="admin",
        )
    else:
        print("==> Superuser already exists, skipping.")

    # 3. collectstatic
    print("==> Collecting static files...")
    call_command("collectstatic", "--noinput")

    # 4. runserver
    print("")
    print("==> Server starting at http://localhost:8000")
    print("    Admin: http://localhost:8000/admin/  (admin/admin)")
    print("    API:   http://localhost:8000/api/")
    print("")
    call_command("runserver")

if __name__ == "__main__":
    main()
