# -*- coding: utf-8 -*-
"""
Created on Thu Sep  4 14:57:10 2014

@author: jeaninehunnicutt
"""
from friday_harbor.structure import Ontology
from friday_harbor.mask import Mask
import friday_harbor.experiment as experiment

import json
import requests

data_dir = '/Applications/anaconda/friday_harbor_data'


#region_specific_injs = [100140756,100140949,100141219,100141599,100141796,100142655,100148142,100149109,112162251,112229103,112306316,112595376,112596790,112670853,112936582,113887162,116903968,117298988,120491896,120814821,120875816,121510421,126117554,126908007,139426984,139520203,141602484,142656218,146077302,156394513,156741826,157062358,157556400,157654817,
#157710335,157711748,158255941,158314278,158435116,159319654,159832064,161458737,166054929,166082128,166083557,166271142,166323186,166323896,166324604,166461899,167794131,168002073,168003640,168163498,168164972,168165712,171276330,176430283,180719293,182467026,182616478,182794184,183461297,183470468,183471174,184167484,184168193,
#263106036,263242463,263780729,264629246,264630019,264630726,266486371,266487079,266644610,272414403,272735030,272735744,272737914,272821309,272822110,278317239,278317945,283019341,283020912,286300594,286312782,286313491,287494320,287495026,287769286,292373346,292374068,292374777,292476595,292792016,292792724,293471629,294396492,294481346,294482052,294484177,297652799,298324391]

# Update 4/22/15 : New list that has the brains above PLUS Amygdala, Subiculum, SNr, and more Auditory & AI_GI_DI
region_specific_injs = [184168899, 166153483, 296048512, 180917660, 174361746, 182294687, 113144533, 277710753, 125832322, 156493815, 181600380, 146858006, 112881858, 158914182, 100141993, 175263063, 292532065, 178488859, 286610216, 286610923, 182226839, 127795906, 127222723, 157063781, 152994878, 122641784, 127649005, 159319654, 166323896, 183461297, 183470468, 126117554, 161458737, 139426984, 139520203, 112596790, 272737914, 176430283, 100149109, 120491896, 158314278, 264630726, 278317239, 166083557, 182794184, 142656218, 157062358, 272414403, 292476595, 286299886, 263242463, 100140756, 157710335, 287494320, 286313491, 157556400, 156394513, 292374068, 168002073, 182616478, 120814821, 166082128, 112670853, 141602484, 180719293, 168164972, 183471174, 156741826, 287769286, 112306316, 158435116, 283019341, 292374777, 293471629, 294396492, 263106036, 157711748, 168165712, 292792724, 184167484, 112229103, 166271142, 292373346, 184168193, 272735744, 294484177, 159832064, 166054929, 100140949, 100148142, 112595376, 166323186, 171276330, 182467026, 264629246, 292792016, 168003640, 266486371, 266644610, 278317945, 286300594, 120875816, 168163498, 272735030, 286312782, 297652799, 100142655, 112162251, 112936582, 117298988, 126908007, 157654817, 158255941, 166324604, 166461899, 264630019, 283020912, 298324391, 263780729, 266487079, 272821309, 287495026, 121510421, 167794131, 294481346, 294482052, 100141219, 100141599, 100141796, 113887162, 116903968, 146077302]


#structures = '''AAA,ACAd,ACAv,ACB,AD,AHN,AId,AIp,AIv,AMB,AMd,AMv,AN,AOB,AON,APN,ARH,AUDd,AUDp,AUDv,AV,BLA,BMA,BST,CA1,CA2,CA3,CEA,CENT,CL,CLA,CLI,CM,COAa,COAp,CP,CS,CUL,CUN,DCO,DG,DMH,DN,DP,DR,ECT,ENTl,ENTm,EPd,EPv,FL,FN,FRP,FS,GPe,GPi,GRN,GU,IA,ICc,ICd,ICe,ILA,IMD,IO,IP,IPN,IRN,LA,LAV,LD,LGd,LGv,LH,LHA,LP,LPO,LRN,LSc,LSr,LSv,MA,MARN,MD,MDRNd,MDRNv,MEA,MEPO,MGd,MGm,MGv,MH,MM,MOB,MOp,MOs,MPN,MPO,MPT,MRN,MS,MV,NDB,NI,NLL,NLOT,NOD,NOT,NPC,NTS,ORBl,ORBm,ORBvl,OT,PA,PAA,PAG,PAR,PARN,PB,PCG,PERI,PF,PFL,PG,PGRNd,PGRNl,PH,PIR,PL,PMd,PO,POL,POST,PP,PPN,PRE,PRM,PRNc,PRNr,PRP,PSV,PT,PTLp,PVH,PVT,PVp,PVpo,PYR,RCH,RE,RH,RM,RN,RR,RSPagl,RSPd,RSPv,RT,SBPV,SCm,SCs,SF,SI,SIM,SMT,SNc,SNr,SOC,SPA,SPFm,SPFp,SPIV,SPVC,SPVI,SPVO,SSp-bfd,SSp-ll,SSp-m,SSp-n,SSp-tr,SSp-ul,SSs,STN,SUBd,SUBv,SUM,SUT,SUV,TEa,TR,TRN,TRS,TT,TU,V,VAL,VCO,VII,VISC,VISal,VISam,VISl,VISp,VISpl,VISpm,VM,VMH,VPL,VPM,VPMpc,VTA,XII'''.split(',')

#5/23/15 I want to do just these, i'm missing a few nuclei
#structures = '''IMD,MD,RH,CM,PR,SMT,PF,LP,PCN,CL,IAM,PVT,PT,RE,IAD,AM,AD,LD,PO,VAL,VM,VPM,AV,RT,VPL'''.split(',')

#9/21/16 Redoing for all structures...
structures = '''IMD,MD,RH,CM,PR,SMT,PF,LP,PCN,CL,IAM,PVT,PT,RE,IAD,AM,AD,LD,PO,VAL,VM,VPM,AV,RT,VPL,AAA,ACAd,ACAv,ACB,AD,AHN,AId,AIp,AIv,AMB,AMd,AMv,AN,AOB,AON,APN,ARH,AUDd,AUDp,AUDv,AV,BLA,BMA,BST,CA1,CA2,CA3,CEA,CENT,CL,CLA,CLI,CM,COAa,COAp,CP,CS,CUL,CUN,DCO,DG,DMH,DN,DP,DR,ECT,ENTl,ENTm,EPd,EPv,FL,FN,FRP,FS,GPe,GPi,GRN,GU,IA,ICc,ICd,ICe,ILA,IMD,IO,IP,IPN,IRN,LA,LAV,LD,LGd,LGv,LH,LHA,LP,LPO,LRN,LSc,LSr,LSv,MA,MARN,MD,MDRNd,MDRNv,MEA,MEPO,MGd,MGm,MGv,MH,MM,MOB,MOp,MOs,MPN,MPO,MPT,MRN,MS,MV,NDB,NI,NLL,NLOT,NOD,NOT,NPC,NTS,ORBl,ORBm,ORBvl,OT,PA,PAA,PAG,PAR,PARN,PB,PCG,PERI,PF,PFL,PG,PGRNd,PGRNl,PH,PIR,PL,PMd,PO,POL,POST,PP,PPN,PRE,PRM,PRNc,PRNr,PRP,PSV,PT,PTLp,PVH,PVT,PVp,PVpo,PYR,RCH,RE,RH,RM,RN,RR,RSPagl,RSPd,RSPv,RT,SBPV,SCm,SCs,SF,SI,SIM,SMT,SNc,SNr,SOC,SPA,SPFm,SPFp,SPIV,SPVC,SPVI,SPVO,SSp-bfd,SSp-ll,SSp-m,SSp-n,SSp-tr,SSp-ul,SSs,STN,SUBd,SUBv,SUM,SUT,SUV,TEa,TR,TRN,TRS,TT,TU,V,VAL,VCO,VII,VISC,VISal,VISam,VISl,VISp,VISpl,VISpm,VM,VMH,VPL,VPM,VPMpc,VTA,XII'''.split(',')

#structures = ['IMD', 'MD']

# cortical sub-regions that the injections fall into subregions = ['ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp']
#
#print structures
#
#region_specific_injs = region_specific_injs[:2]

targetAreas = []

numInjections = len(region_specific_injs)

# Initialize
ontology = Ontology(data_dir=data_dir)
#areas = ontology.acronym_id_dict[??]

#IDs = ontology.id_acronym_dict  #up here I stopped midway through making it loop through all areas, come back after I get it working below


# Call the website to get the density and projection volume data by subregion for each injection
BASE_URL = 'http://connectivity.brain-map.org/api/v2/data/ProjectionStructureUnionize/query.json?criteria=[section_data_set_id$eq'
END_URL = ']&num_rows=all'

all_structure_ids = set()

structure_objects = [ontology.structure_by_acronym(s) for s in structures] #The parent stuff below makes this a little unnecesarry... 

table = []
for injID in region_specific_injs:  #loop through all of the relevent injections
#    q = str(112514202)
    q = str(injID)  
    def query(q):   # Go to this web page and get the results (which includes a lot more info than I'm using)
        url = BASE_URL + q + END_URL
        
        r = requests.get(url)
        rjson = r.json()
        
        success = rjson.get('success', False)
        
        if not success:
            return None
        else:
            return rjson['msg']
    
    results = query(q)  # access the results queried above.
    for result in results:  # Creating a continuous table of the projection densities from each injection to all 214 other areas
        if result['hemisphere_id'] == 2:
            structure_id = result['structure_id']
            if ontology.id_structure_dict.has_key(structure_id):
    
                s = ontology.structure_by_id(structure_id)
                for parent_structure in structure_objects:  
    #                if s.is_child_of(parent_structure):
                    if s == parent_structure:    #This limits the ontology to only the 214 parent groups (i.e. omits layers, sub-groups, etc. )
                        parent_id = parent_structure.structure_id
                        row = []
                        row.append(result['section_data_set_id'])
                        row.append(parent_id)
                        row.append(result['projection_density'])
                        row.append(result['projection_volume'])
                        all_structure_ids.add(parent_id)
                        table.append(row)
                        break
    print injID
#    print results
#print "section_data_set_ids:"

x = '/Applications/anaconda/friday_harbor_data'
em = experiment.ExperimentManager(data_dir = x) #data_dir is the keyword it is expecting

# Save the injection specific information to be used in as nodes in Gephi
injid_file = open('injid_2016_ipsi.csv', 'w')
for injID in region_specific_injs:
    injid_file.write("%s,%s,%s\n" % (injID, em.experiment_by_id(injID).structure_abbrev, em.experiment_by_id(injID).injection_mask().centroid))
injid_file.close()   

# Save the ontology specific information to be used in as nodes in Gephi
structure_id_file = open('structure_ids_2016_ipsi.csv', 'w')
for acronym in all_structure_ids:
    structure_id_file.write("%s,%s,%s,%s\n" % (acronym, ontology.id_acronym_dict[acronym], ontology.get_mask_from_id_right_hemisphere_nonzero(acronym).centroid, ontology.id_structure_dict[acronym].name))
structure_id_file.close()

# Save the projection densities from each injection to all 214 other areas
edges_file = open('edges_2016_ipsi.csv', 'w')
for row in table:
    for cell in row:
        edges_file.write("%s," % cell)
    edges_file.write("\n")
edges_file.close()   

#    the centroids are returned as [x y z] where x:A-P y:D-V & z:M-L
# in Gephi I want A-P to be in their X @1-1200, and D-V to be in their Y @ 1-800 (so x=X and y=Y)

# to look at something within these results:
# results[0]['structure_id'] 
# where the [0] is looking at the first structure 
# and the ['structure_id'] is one of the 
#hemisphere_id # 1:left  2:right 3:sum of left and right
