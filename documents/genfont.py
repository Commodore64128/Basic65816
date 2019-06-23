font = [x for x in bytes(open("challenger.rom","rb").read(-1))]
#font = font[0x3800:0x4000]
h = open("c64font.h","w")
font = ",".join([str(x) for x in font])
h.write("const BYTE8 font[] = { "+font+ "};\n\n")
h.close()