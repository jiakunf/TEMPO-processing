# TEMPO processing pipeline 

## Introduction

This is a pipeline for converting dual-channel TEMPO microscopy recordings to dF/F movies with physiological and recording artifacts removed via convolution unmixing procedure.

## Installation

This pipeline was tested in MATLAB 2019b, 2021b, and 2023a.

Add all folders (except _pipelines_) to MATLAB path. Add all **dependencies** to MATLAB path.

### Dependencies
#### matlab toolboxes
_dependencies_toolboxes.txt_
availible from MathWorks

#### external matlab libraries
_dependencies_external.txt_
availible from other developers through mathworks.com/matlabcentral or github.com

#### internal matlab utils
_dependencies_utils.txt_
availible upon request; will be publicly availible upon release

#### binary files
_dependencies_binaries.txt_
For .dcimg to .h5 conversion, binary files _dcimgmex.mexw64_ / _dcimgmatlab.mexw64_, _dct_readtimestamps.exe_, and sdk drives from Hamamatsu are required. Availible from Hamamatsu
For fast filtering (td convolution), compiled _hdf5_movie_convolution.exe_ and open source linear algebra and fft libraries are required. Availible upon request 

## Getting Started

<img src="https://github.com/user-attachments/assets/97722aff-dbc5-448f-88aa-68a67d7aa749" width="20%" align="right" alt="movie processing pipeline">

Browse the example pipelines in _pipelines_ folder.

### Preprocessing
_pipelines\pipeline_preprocessing_2xmoco.m_ <br/>
Data preprocessing that includes independent motion correction of both channels and  registration of the reference channel to the signal channel.

### Unmixing

<img src="https://github.com/user-attachments/assets/d973468d-b127-4c0b-8dce-6c65bc39e89d" width="40%" alt="convolutional unmixing - data model">
<img src="https://github.com/user-attachments/assets/d8f68623-2a69-43bc-af32-5ddb5bef436d" width="40%" alt="convolutional unmixing - algorithm">


_pipelines\pipeline_unmixing.m_ <br/>
Unmixing of physiological and recording artifacts. Decrosstalking, high-pass filtering, convolutional unmixing, and F0 normalization.




## Citations

This processing pipeline is described in **upcoming biorxiv link** [Haziza et al., 2024](https://www.biorxiv.org/). The convolutional unmixing procedure was first introduced in a talk [Kruzhilin et al., 2023](https://www.sfn.org/-/media/SfN/Documents/NEW-SfN/Meetings/Neuroscience-2023/Abstracts/Abstract-PDFs/SFN23_Abstracts-PDF-Nano.pdf). Please cite us if you use this pipeline in your own work.

## License
