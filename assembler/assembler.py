
import sys
import os

inst_depth = 256

input_file = sys.argv

op_decode = {
    'nop':0b0000,
    'add':0b0001,
    'sw' :0b0010,
    'lw' :0b0011,
    'mv' :0b0100,
    'and':0b0101,
    'xor':0b0101,
    'or' :0b0101,
    'not':0b0101,
    'jmp':0b0110,
    'bgt':0b0110,
    'blt':0b0110,
    'beq':0b0110,
    'sll':0b0111,
    'srl':0b0111
}

mode_decode = {
    'nop':0b000,
    'add':0b000,
    'sw' :0b000,
    'lw' :0b000,
    'mv' :0b000,
    'and':0b000,
    'xor':0b001,
    'or' :0b010,
    'not':0b011,
    'jmp':0b000,
    'bgt':0b001,
    'blt':0b010,
    'beq':0b011,
    'sll':0b000,
    'srl':0b001
}

reg_decode = {
    '$0' :0b000,
    '$p' :0b001,
    '$t0':0b010,
    '$t1':0b011,
    '$t2':0b100,
    '$t3':0b101,
    '$i0':0b110,
    '$i1':0b111
}

ml_txt_file =  os.path.splitext(input_file[1])[0] + '_ml.txt'
ml_mif_file = os.path.splitext(input_file[1])[0] + '_ml.mif'

f_ml = open(ml_txt_file, 'w')
f_ml_mif = open(ml_mif_file, 'w')

f_ml_mif.write(f'WIDTH=16;\nDEPTH={str(inst_depth)};\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\nCONTENT BEGIN\n')

num_of_inst = 0

with open(input_file[1]) as f_as:
    for l in f_as:
        i=0
        inst = l.split()

        # アセンブリの[,]を削除
        for word in inst:
            inst[i] = word.strip(',')
            i += 1

        # アセンブリ→機械語変換
        op = '{:04b}'.format(op_decode[inst[0]])
        if(inst[0] == 'mv'): # I形式
            dr = '{:03b}'.format(reg_decode[inst[1]])
            ml = op + dr + inst[2] + '0'
        else: # R形式
            mode = '{:03b}'.format(mode_decode[inst[0]])
            sra = '{:03b}'.format(reg_decode[inst[1]])
            srb = '{:03b}'.format(reg_decode[inst[2]])
            dr = '{:03b}'.format(reg_decode[inst[3]])
            ml = op + sra + srb + dr + mode

        ml_txt = ml + ' // ' + l

        print(ml_txt.replace('\n',''))
        f_ml.write(ml_txt)
        f_ml_mif.write(str(num_of_inst) + ' : ' + ml + ';\n')
        num_of_inst += 1

f_ml_mif.write('[' + str(num_of_inst) + '..' + str(inst_depth -1) + '] : 0000000000000000;' + '\nEND;')

f_ml.close()