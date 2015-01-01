try:
    fh = open("testfile", "r")
    contenu=fh.read()
    print(contenu)
except IOError:
    print()
else:
    fh.close()
