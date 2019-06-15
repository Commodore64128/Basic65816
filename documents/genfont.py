font = [x for x in bytes(open("pet-2.bin","rb").read(-1))]
h = open("c64font.h","w")
font = ",".join([str(x) for x in font])
h.write("const BYTE8 font[] = { "+font+ "};\n\n")
h.close()