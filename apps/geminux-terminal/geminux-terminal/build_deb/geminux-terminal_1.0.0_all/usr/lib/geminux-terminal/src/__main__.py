#!/usr/bin/env python3
import sys
import os

# Set up module path
sys.path.insert(0, '/usr/lib/geminux-terminal')
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from src.app import main

if __name__ == '__main__':
    sys.exit(main())
