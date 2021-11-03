#! /usr/bin/env python3

# add resname in 'residue name list'
def add_name(namedict,resnum,resname):
    namedict_key = list(namedict.keys())
    if resnum not in namedict_key:
        namedict[resnum] = resname


# add ec value in 'ec value dict'
# ec valuedict {resnumber : { pairnumber : [ data0, data1, .. ] , ..}, .. }
def add_value(valuedict,resnum,pairnum,ecvalue):
    valuedict_key = list(valuedict.keys())
    if resnum in valuedict_key:
        pairdict = valuedict[resnum]
        pairdict_key = list(pairdict.keys())
        if pairnum in pairdict_key:
            value_list = pairdict[pairnum]
            value_list.append(ecvalue)
            pairdict[pairnum] = value_list
        else:
            pairdict[pairnum] = [ecvalue]
        valuedict[resnum] = pairdict
    else:
        pairdict = {pairnum:[ecvalue]}
        valuedict[resnum] = pairdict


#main
if __name__ == '__main__':

    import math
    import sys

    if len(sys.argv)==1:
        print('USAGE : ./average.py [ec data files ..]')
        exit()

    # get input file names
    file_list=[]
    for i,fname in enumerate(sys.argv):
        if i==0: continue
        file_list.append(fname)

    value_num = len(file_list)
    ave_file = 'ec_average.dat'

    # data dicts
    name_dict = {}
    ec_dict = {}

    print('data files')
    for file_num,filename in enumerate(file_list):
        f = open(filename,'r')
        for i,line in enumerate(f):
            l = line.split()
            res1,res2 = l[0].split('_'),l[1].split('_')
            num1,num2 = int(res1[0]),int(res2[0])
            name1,name2 = res1[1],res2[1]
            value = float(l[2])
            #print("{0} : {1}".format(data_id,line)) ##
            add_name(name_dict,num1,name1)
            add_name(name_dict,num2,name2)
            add_value(ec_dict,num1,num2,value)

        f.close()
        print("{0:0>3} : {1}".format(file_num,filename))

    print()
    #print(name_dict)
    #print(ec_dict)

    # output data
    res_list = list(ec_dict.keys())
    res_list.sort()

    fo = open(ave_file,'w')

    for resnum in res_list:
        pair_list = list(ec_dict[resnum].keys())
        pair_list.sort()
        resname = name_dict[resnum]
        for pairnum in pair_list:
            pairname = name_dict[pairnum]
            value_list = ec_dict[resnum][pairnum]
            #value_num = len(value_list)
            #print("{0:0>3}_{1} {2:0>3}_{3}  {4} {5}\n".format(resnum,resname,pairnum,pairname,value_num,value_list))
            value_sum = 0
            value_sqr = 0
            for value in value_list:
                value_sum += value
                value_sqr += value**2
            value_ave = value_sum/value_num
            value_sqr = value_sqr/value_num
            value_dev = math.sqrt(value_sqr - value_ave**2)
            fo.write("   {0:0>5}_{1}  {2:0>5}_{3}  {4}  {5}\n".format(resnum,resname,pairnum,pairname,value_ave,value_dev))


    fo.close()




