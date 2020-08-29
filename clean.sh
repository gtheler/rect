# from https://stackoverflow.com/questions/13541615/how-to-remove-files-that-are-listed-in-the-gitignore-but-still-on-the-repositor
cat .gitignore | grep -v red | sed '/^#.*/ d' | sed '/^\s*$/ d' | sed 's/^/rm -rf /' | bash
