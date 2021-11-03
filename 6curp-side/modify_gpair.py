#! /usr/bin/env python3

def gen_data(filename):
    f = open(filename)
    for line in f:
        if '#' in line: continue
        l = line.split()
        yield l
    f.close()

#[00015_PHE]
#00022_LEU  00017_THR  00020_GLU  00035_VAL  00018_ALA  00029_GLU  00021_ARG  00031_ILE  00033_GLN  00028_LEU  00025_TRP  00105_HEM  00023_PHE  00026_SER  00019_ALA  00032_GLY  00038_LEU  00100_VAL  00016_SER  00024_GLY  00027_GLU  00037_ILE  00030_ALA

def separate_resid(resid,not_sep_list):
    res = resid.split('_')
    res_list = []
    resnumber,resname = int(res[0]),res[1]
    if resnumber in not_sep_list:
        res_list.append((resnumber,resname))
    else:
        res_list.append((resnumber,resname+'-Main'))
        res_list.append((resnumber,resname+'-Side'))
    return res_list

def pickup_gpair(filename,not_sep_list):
    res_donar = []
    for gpair_line in gen_data(filename):
        if len(res_donar) != 0:
            for resid in gpair_line:
                res_acceptor.extend(separate_resid(resid,not_sep_list))
            yield (res_donar,res_acceptor)
            res_donar = []
        if '[' in gpair_line[0]:
            resid = gpair_line[0][1:-1]
            res_donar = separate_resid(resid,not_sep_list)
            res_acceptor = []

def make_print_line(gpair_data):
    donar,acceptor = gpair_data
    for donar_number,donar_name in donar:
        print_line_donar = '[{0:0>5}_{1}]'.format(donar_number,donar_name)
        print_line_acceptor = ''
        for acceptor_number,acceptor_name in acceptor:
            print_line_acceptor+='{0:0>5}_{1} '.format(acceptor_number,acceptor_name)
        print_line_acceptor.rstrip(' ')
        yield print_line_donar,print_line_acceptor


def main():
    import sys
    if len(sys.argv)<2:
        print('USAGE : ./mod_gpair.py [gpair file] [not separated residue numbers]\n')
        exit()

    filename = sys.argv[1]
    not_sep_list = [ int(i) for i in sys.argv[2:] ]

    for gpair_data in pickup_gpair(filename,not_sep_list):
        #print(gpair_data)
        for print_line_donar,print_line_acceptor in make_print_line(gpair_data):
            print(print_line_donar)
            print(print_line_acceptor)

if __name__ == '__main__':
    main()
