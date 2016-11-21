# Documentation of Anatomy Analysis Code
> This is the analysis code for the striatal portion of my PhD thesis work: "A comprehensive map of excitatory input convergence in the mouse striatum." The corticostriatal dataset was generated from data produced by the [Allen Institute for Brain Science](http://connectivity.brain-map.org/projection) (AIBS) & the thalamostriatal dataset generated from data produced by us for a [previous study](http://digitalcollections.ohsu.edu/projectionmap).

---
### Data Sources:

[Thalamic Projections](http://digitalcollections.ohsu.edu/projectionmap)
: Hunnicutt, B. J. et al. (2014). A comprehensive thalamocortical projection map at the mesoscopic level. Nature Neuroscience. 17, 1276–1285.

[Cortical Projections](http://connectivity.brain-map.org/projection)
: Oh, S. W. et al. (2014). A mesoscale connectome of the mouse brain. Nature 508, 207–214.


---
### Overview of Analysis Code (in order of use):
* [Python/\*](https://github.com/BJHunnicutt/anatomy/tree/master/Python)
* [Matlab/\*](https://github.com/BJHunnicutt/anatomy/tree/master/Matlab)


| File Name					| Folder |	Purpose
| ----------------------------------|-------------
| 1. jh_export2matlab4.py | Python |	Get voxelized AIBS data out of python
| 2. jh_GetDensityDataFromWeb.py | Python |	Access density data from AIBS API
| 3. jh_pImport2matlab2.m			| Matlab |	Get AIBS data aligned & prepped for analysis
| 4. jh_AllenInstituteBundleSubtraction.m	| Matlab |	Remove bundled projections from AIBS data
| 5. jh_consolidatingAIBSdatasets.m	| Matlab |	Group injection data by cortical origin
| 6. jh_corticostriatalFigures.m | Matlab | Generate figures for corticostriatal data alone
| 7. jh_voxelClustering_striatum.m | Matlab | Create striatal subdivisions based on convergent cortical inputs
| 8. jh_consolidatingThalamusData.m | Matlab | Get thalamic injections, group them, calculate coverage & nuclear coverage
| 9. jh_consolidatingAIBS_forNetworkAnalysis.m | Matlab | Generate data for network analyses
| 10. jh_assortedStriatumFigures.m | Matlab | Generate several example figures for methods and background


---
### Thalamostriatal Data Generation:
 * [/Matlab/thalamostriatal/\*](https://github.com/BJHunnicutt/anatomy/tree/master/Matlab/thalamostriatal)

| File Name					|	Purpose
| ----------------------------------|-------------
| 1. jh_segmentstriatum.m | Create manual striatum masks
| 2. jh_strRot.m | Manually select striatal landmarks used for alignment
| 3. jh_checkingStrPts.m | Check manually selected points
| 4. jh_createStrMaskedTiffs.m | Generate tiffs cropped by the striatum mask
| --> WEKA Image Segmentation machine learning algorythm implemented via ImageJ | Select and train image subset, then apply WEKA machine learning (ML) algorithm to all images. Output => WEKA Probability Images for diffuse projection localization
| 5. jh_threshold_WEKA.m | GUI to manually select probability thresholds ( Requires: jh_threshold_WEKA.fig)
| 6. jh_WEKAprobToMask.m | Apply the selected thresholds to the probability masks
| 7. jh_finalProjMaskAdjustments_green.m | Manual correction of small errors in automated WEKA ML output for green channel (Requires: jh_finalProjMaskAdjustments_green.fig)
| 8. jh_finalProjMaskAdjustments_red.m | Manual correction of small errors in automated WEKA ML output for red channel (Requires: jh_finalProjMaskAdjustments_red.fig)
| 9. jh_createFinalProjMasks.m | Generate final projection masks that include manual adjustments and holes caused be traveling axons filled
| 10. jh_createFinalProjMasks_fixaddMaskMistake.m | Ran after jh_createFinalProjMasks.m to fix a small error.

##### See: [/Matlab/thalamostriatal/README.md](https://github.com/BJHunnicutt/anatomy/blob/master/Matlab/thalamostriatal/README.md) for implementation details.


<!-- | jh_trainedStrProjMaskGen.m | Creates colormask.mat to subract aberrantly localized projections * Originally did this after jh_WEKAprobToMask.m, then refined with jh_finalProjMaskAdjustments... GUIs, but jsut starting with the GIUS works too-->

---
### Other Information:
##### Required Matlab Functionality:
* Image Processing Toolbox
* Statistics and Machine Learning Toolbox
* [Medical Image Processing Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/41594-medical-image-processing-toolbox) by Alberto Gomez


##### Helper functions required for the code above:
* See: [/Matlab/auxillary_funcitonsAndScripts/...](https://github.com/BJHunnicutt/anatomy/tree/master/Matlab/auxillary_funcitonsAndScripts)

##### Collection of template masks, data, and settings required above:
* See: [/Matlab/masks/...](https://github.com/BJHunnicutt/anatomy/tree/master/Matlab/masks)

##### Striatum alignment for thalamostriatal data:
* See: */Matlab/striatum_alignment/...*
* Currently in the .gitignore - Need to ask Haining about putting this code in here with attribution
