#! /usr/bin/env python3

def gen_data(file_name):
    f = open(file_name,'r')
    for line in f:
        if '#' in line: continue
        l = line.split()
        atom_num,atom = int(l[0]),l[1]
        res_num,resid =int(l[2]),l[3]
        yield (res_num,resid,atom_num,atom)
    f.close()
    ##Atom Name  #Res Name  #Mol Type   Charge     Mass GBradius El
    #1 HH31     1 ACE      1 HC     0.1123   1.0080   1.3000  H

def resid_group(file_name):
    prev_resid = (-1,None)
    resid_atoms = []
    for atom_data in gen_data(file_name):
        res_number,res_name,atom_number,atom_name = atom_data
        if prev_resid[0] < 0:
            prev_resid = (res_number,res_name)
            resid_atoms.append((atom_number,atom_name))
        else:
            if res_number == prev_resid[0]:
                resid_atoms.append((atom_number,atom_name))
            else:
                yield prev_resid,resid_atoms
                resid_atoms.clear()
                resid_atoms.append((atom_number,atom_name))
                prev_resid = (res_number,res_name)
    if len(resid_atoms)!=0:
        yield prev_resid,resid_atoms

main_chain_atoms = ['N','H','CA','HA','C','O']

def separate_group(atoms):
    main,side = [],[]
    for atom_number,atom_name in atoms:
        if atom_name in main_chain_atoms:
            main.append(atom_number)
        else:
            side.append(atom_number)
    return main,side

def output_range(first_number,last_number):
    if first_number == last_number:
        atom_range = '{0}'.format(first_number)
    else:
        atom_range = '{0}-{1}'.format(first_number,last_number)
    return atom_range

def list_range(atomlist):
    first,last = -1,-1
    for number in atomlist:
        if first < 0:
            first,last = number,number
        else:
            if number - last == 1:
                last = number
            else:
                atom_range = output_range(first,last)
                first,last = number,number
                yield atom_range
    atom_range = output_range(first,last)
    yield atom_range

def output_group(groupname,atomlist):
    print('[{0}]'.format(groupname))
    atom_line = ''
    for atom_range in list_range(atomlist):
        atom_line+='{0} '.format(atom_range)
    atom_line.rstrip(' ')
    atom_line+='\n'
    print(atom_line)

def main():
    import sys
    if len(sys.argv) < 2:
        print('USAGE : ./gen_atomgroup.py [cpptraj atominfo file] [No separate residue number]\n')
        print('residue in [No separate residue number] are not separated in side chian and main chain.')
        print('   example : "ACE","NME" or Ligand,Cofactor\n')
        print('ex. ./atomgroup.py atominfo 1 104 105 ')
        print('   -> resid 1,104,105 are not separated.\n')
        exit()
    filename = sys.argv[1]
    no_sep_res = [ int(i) for i in sys.argv[2:]]

    for resid_atom_data in resid_group(filename):
        resinfo,atoms = resid_atom_data
        if resinfo[0] in no_sep_res:
            atom_numbers = [ num for num,name in atoms ]
            group_name = '{0:0>5}_{1}'.format(resinfo[0],resinfo[1])
            output_group(group_name,atom_numbers)
        else:
            main_chain,side_chain = separate_group(atoms)
            group_name = '{0:0>5}_{1}'.format(resinfo[0],resinfo[1])
            output_group(group_name+'-Main',main_chain)
            output_group(group_name+'-Side',side_chain)

if __name__ == '__main__':
    main()
