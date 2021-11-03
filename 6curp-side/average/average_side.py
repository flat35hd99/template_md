#! /usr/bin/env python3
# 2017.5.23.

def add_name_dict(namedict,resnumber,resname,restype): # add resname in 'residue name list'
# {resnumber : [resname,[restype1,restype2]]} i.e. {1: [ ALA,[Main,Side] ]}
    namedict_key = namedict.keys()
    if resnumber not in namedict_key:
        namedict[resnumber] = (resname,[restype])
    else:
        name_tuple = namedict[resnumber]
        if restype not in name_tuple[1]:
            restype_list = name_tuple[1]
            restype_list.append(restype)
            namedict[resnumber] =  (resname,restype_list)



def add_value_dict(valuedict,resid1,resid2,ecvalue): # add ec value in 'ec value dict'
# ec valuedict {(res1,res2) : [value list]}
    valuedict_key = valuedict.keys()
    pair = (resid1,resid2)
    if pair in valuedict_key:
        value_list = valuedict[pair]
        value_list.append(ecvalue)
    else:
        value_list = [ ecvalue ]
    valuedict[pair] = value_list


def gen_line_data(filename):
    try:
        f = open(filename,'r')
    except:
        print("Can't Open file : {0}".format(filename))
        exit()
    else:
        for line in f:
            l = line.split()
            res1,res2,value = l[0],l[1],float(l[2])
            yield res1,res2,value
        f.close()


def resid_converter(resid): #resid = 'resnumber_resname' i.e. '00012_ALA' or '00004_GLU-Side'
    res = resid.split('_')
    resnumber,resname = int(res[0]),res[1]
    if '-' in resname:
        resname = resname.split('-')
        restype = resname[-1]
        resname = resname[0]
    else:
        restype = None
    return resnumber,resname,restype


def input_data(file_list):
    name_dict = {}
    ec_dict = {}
    print("data file")
    for filenumber,filename in enumerate(file_list):
        for res1,res2,value in gen_line_data(filename):
            num1,name1,type1 = resid_converter(res1)
            num2,name2,type2 = resid_converter(res2)
            add_name_dict(name_dict,num1,name1,type1)
            add_name_dict(name_dict,num2,name2,type2)
            add_value_dict(ec_dict,(num1,type1),(num2,type2),value)
        print("{0:0>3} : {1}".format(filenumber,filename))
    return name_dict,ec_dict


def calc_data(value_list,value_number):
    import math
    value_sum = 0
    value_sqr = 0
    for value in value_list:
        value_sum += value
        value_sqr += value**2
    value_avg = value_sum/value_number
    value_sqr = value_sqr/value_number
    value_var = value_sqr - value_avg**2
    value_dev = math.sqrt(value_var)
    return value_avg,value_dev


def gen_output_name(resnumber,resname,restype):
    if restype == None:
        output_name = "{0:0>5}_{1}".format(resnumber,resname)
    else:
        output_name = "{0:0>5}_{1}".format(resnumber,resname+'-'+restype)
    return output_name


def gen_output_line(name_dict,ec_dict,value_number):
    resid_list = list(name_dict.keys())
    resid_list.sort()

    for i,resnumber1 in enumerate(resid_list):
        resid1 = name_dict[resnumber1]
        resname1 = resid1[0]
        restype_list1 = resid1[1]
        resid_pair_list = resid_list.copy()
        resid_pair_list = resid_pair_list[i+1:]
        for restype1 in restype_list1:
            for resnumber2 in resid_pair_list:
                #if resnumber2 >= resnumber1: continue
                resid2 = name_dict[resnumber2]
                resname2 = resid2[0]
                restype_list2 = resid2[1]
                for restype2 in restype_list2:
                    ec_dict_key = ec_dict.keys()
                    pair = ((resnumber1,restype1),(resnumber2,restype2))
                    if pair not in ec_dict_key: continue
                    value_list = ec_dict[((resnumber1,restype1),(resnumber2,restype2))]
                    value_avg,value_dev = calc_data(value_list,value_number)
                    output_name1 = gen_output_name(resnumber1,resname1,restype1)
                    output_name2 = gen_output_name(resnumber2,resname2,restype2)
                    outputline = "   {0}  {1}  {2}  {3}\n".format(output_name1,output_name2,value_avg,value_dev)
                    yield outputline


def main():
    import sys
    if len(sys.argv)==1:
        print('USAGE : ./average.py [ec data files ..]')
        exit()

    # get input file names
    file_list = sys.argv[1:]

    value_number = len(file_list)
    avg_file = 'ec_average.dat'

    # data dicts
    name_dict = {}
    ec_dict = {}

    name_dict,ec_dict = input_data(file_list)
    #print(name_dict)
    #print(ec_dict)

    # output data
    of = open(avg_file,'w')

    for outputline in gen_output_line(name_dict,ec_dict,value_number):
        of.write(outputline)
        #print(outputline)
    of.close()


if __name__ == '__main__':
    main()


