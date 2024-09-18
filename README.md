# Contents

- [Summary of Contents of Repository](#summary-of-contents-of-repository)
- [Dataset Details](#dataset-details)
- [Metadata For The Recording](#metadata-for-the-recording)
- [Processing Flowcharts](#processing-flowcharts)
- [Audio Processing and Pitch Extraction](#audio-processing-and-pitch-extraction)
  - [Part 1: From Raw Audio to Source Separated Audio](#part-1-from-raw-audio-to-source-separated-audio)
  - [Part 2: From Source Separated Audio to Pitch Contours](#part-2-from-source-separated-audio-to-pitch-contours)
- [Video Time Series Processing](#video-time-series-processing)
  - [Part 1: From Keypoints to Time Series](#part-1-from-keypoints-to-time-series)
  - [Part 2: Velocity and Acceleration Estimation](#part-2-velocity-and-acceleration-estimation)
- [Using Processed Master Files](#using-processed-master-files)
- [Use in Previous Work](#use-in-previous-work)
- [Replicating the Processing of This Repository](#replicating-the-processing-of-this-repository)
  - [Before You Start](#before-you-start)
  - [Downloading the Data](#downloading-the-data)
  - [Data Processing](#data-processing)


This is the code repository for multimodal processing of Hindustani Raga music. The data for this project is available on OSF at [Hindustani Vocal Audio Visual Correspondence](https://osf.io/qjkzs/). The OSF project has a component detailing the Ethical Use Declaration. 

This repository covers the chain of processing as well as intermediate outputs for the following overall task:  Video (mp4) of raga alap (or pakad) performed by a singer is processed to obtain a CSV "masterfile" containing the time series (sampled at 10 ms intervals) of singer pitch (cents with reference to singer tonic), gesture (3d position, velocity, acceleration) from selected keypoints (elbow, wrist). We used this code on our full video dataset of 11 singers singing alap/pakad pieces in each of 9 ragas, each performance having 3 camera views, to generate the following processed data files (one of each file type per singer): 
- Masterfile: A csv file containing the computed pitch and gesture contours for that singer across all the pieces sung by the singer
- Offsets information: A text file containing start and end timestamps. This information helps to associate each original video's timestamps with corresponding masterfile timestamps (which may be different due to the deletion of singer's spoken introduction from the audio extract).
- Singer tonic: A text file containing the singer's tonic in Hz

## Summary of Contents of repository

| Folder Name                | Description |
| -------------------------- | ----------- |
| 00_data                    | This is the data folder meant to hold the original video(s), text files for each singer with the start and stop times for the actual singing in each video and the singer specific tonic. |
| 01_openpose_output              | This is the output of 2D coordinates from the OpenPose processing using the front view only. |
| 01_videopose_output        | This is the output of the 3D coordinates from VideoPose3D library. This uses all the 3 views of the recording. |
| 02_audio_processing        | This has the code for the processing of the already source-separated audio |
| 03_audio_processing_data | This is where the audio processing code expects to finds the input audio, and also places its output |
| 04_video_processing        | This is the location for the video processing code (SavGol filtering, 10 ms resampling, and Z-score normalization) which converts the output of either OpenPose or VideoPose3D into time series at 10ms intervals |
| 05_video_processing_output | This is where the video processing code places its output |
| 06_multimodal_processing   | This is the location of code for the computation of velocity and acceleration and combination of audio and video processing output |
| 07_multimodal_processing_output | This is where the masterfile (output of above multimodal processing) is stored. |

**IMPORTANT NOTE** :-  We provide the output for audio processing, video processing and master files for one sample recording - AK_Pakad_Bag in this repository. This is ONLY for the user to be acquainted with the data structure. Either download the final master files from [Using Processed Master Files](#using-processed-master-files) or replicate the processing by following the steps in [Replicating the Processing of This Repository](#replicating-the-processing-of-this-repository)


## Dataset Details

The dataset consists of recordings by 11 singers (5 Male, 6 Female) performing 9 ragas. Each singer has 2 alaps and 1 pakad recording per raga (with a few exceptions). This dataset is an expansion of the raga alap component of the dataset [Raga Pose Estimation](https://github.com/DurhamARC/raga-pose-estimation). The original raga alap dataset contains the audiovisual recordings of 3 singers (AG/CC/SCh) singing the same 9 ragas. We refer to the singers in the earlier version of this dataset as Durham Singers (since the recording was done in Durham) and the rest of the singers as Pune Singers in our discussion below. 

The image below shows the setup (not to scale) for the three cameras for the Pune singers. The angle between the front and the right camera is
approximately 55 degrees and the front and left camera is approximately 47 degrees. We refer to left and right camera based on
the singer's point of view.

<div align="center">
  <img src="cameraSetupPuneSingers.png" alt="Recording Setup for Pune Singers">
  <p>Recording setup</p>
</div>

 

| **Singer Name** | **Initials** | **Gender** | **Ragas** | **#Pakad** | **#Alap** | **Dur(min)** |
| - | - | - | - | - | - | - |
| Apoorva Gokhale | AG | F | 9 | 9 | 17 | 54 |
| Adwait Keskar | AK | M | 9 | 9 | 18 | 60 |
| Adishri Pote | AP | F | 9 | 9 | 18 | 59 |
| Chiranjeeb Chakraborty | CC | M | 9 | 10 | 18 | 71 |
| Mandar Gadgil | MG | M | 9 | 9 | 18 | 58 |
| Meher Paralikar | MP | M | 9 | 9 | 18 | 59 |
| Nishad Matange | NM | M | 9 | 9 | 18 | 55 |
| Rashika Varkat Garud | RV | F | 9 | 9 | 18 | 60 |
| Sudokshina Chatterjee | SCh | F | 9 | 18 | 20 | 67 |
| Shivani Marulkar Dassakar | SM | F | 9 | 9 | 18 | 60 |
| Sawani Shikare | SS | F | 9 | 9 | 18 | 60 |
| | | **5M,6F** | **9** | **109** | **199** | **664** |



The tonic of each singer is provided in the text files in 00\_data/02\_singer\_specific\_tonic  

Following are the ragas used in the recordings. Some raga names are abbreviated.

| **Raga** | **#Pakad** | **#Alap** | **Duration** |
|----------|------------|-----------|--------------|
| Bageshree (Bag) | 12 | 22 | 73 |
| Bahar | 12 | 22 | 70 |
| Bilaskhani Todi (Bilas) | 13 | 22 | 73 |
| Jaunpuri (Jaun) | 12 | 22 | 72 |
| Kedar | 12 | 22 | 72 |
| Marwa | 12 | 22 | 76 |
| Miyan ki Malhar (MM) | 12 | 23 | 78 |
| Nand | 12 | 22 | 74 |
| Shree | 12 | 22 | 75 |
| **ALL** | **109** | **199** | **664** |


## Metadata for the recording

|**Audio Metadata**|Sample Rate|48000 Hz|
| - | - | - |
||Bit Depth|24 bit|
||Audio Codec|AAC|


|**Video Metadata**|Format|MP4|
| - | - | - |
||Resolution|1920\*1080|
||Video Codec|H.264 High L4.0|
||FPS|25 for singers AG,CC,SCh. 24 for others|

## Processing Flowcharts

The repository can process both single-view and multiple-view recordings. The following diagrams show the processes for 2D and 3D. We use [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) for keypoint estimation from front view only and [VideoPose3D](https://github.com/facebookresearch/VideoPose3D) for keypoint extraction from 3 views.

| ![Processing with front view camera only](Process2D.png) | ![Processing with all 3 view cameras](Process3D.png) |
|:---------------------------------------------------------:|:----------------------------------------------------:|
| Processing with front view camera only                    | Processing with all 3 view cameras                   |


## Audio Processing and Pitch Extraction

### Part 1: From Raw Audio to Source Separated Audio

For Pune singers (AK, AP, MG, MP, NM, RV, SM, SS), we used [**Spleeter Source separation**](https://research.deezer.com/projects/spleeter.html) (4 stem model) 

For Durham singers (AG, CC, SCh) we used [**Audacity Noise Removal**](https://manual.audacityteam.org/man/noise_reduction.html) (called ANR hereupon) – the parameters are mentioned in the following explanation

This choice was made based on some trial and error. We had three choices for the source separation:

1) Using Spleeter Only
1) Using ANR only
1) Using ANR followed by Spleeter (ANR+Spleeter)

The drawback of using Spleeter was that some portion of the vocals was getting lost because of the aggressiveness of the source separation. The drawback of using ANR was that it was not as effective as Spleeter in removing the accompaniment (Tanpura). So we had to make the best of the tradeoff.

We noticed the following:

**Pune Singers:**

For SM, the voice was loud enough so ANR was working well. But it was not working better than Spleeter. For other Pune Singers ANR is working worse than Spleeter. So for the Pune singers, using Spleeter only was the best. Audacity noise removal is not helpful, irrespective of whether we use Spleeter or not. Because of the loud tanpura, we need the aggressive splitting of Spleeter to get the separated vocals.

**Durham Singers:**

For Durham singers, low pass filtering followed by noise removal worked well. After that, we could use Spleeter to be extra sure or we could do without it as well (the difference was negligible). For CC and AG, ANR only and ANR + Spleeter were working much better than Spleeter only. For SCh the difference is not so significant. The tanpura is soft enough so that all methods give decent pitch contours but ANR is still better than Spleeter.

Steps in ANR:

1. Low pass filter (2400 Hz, 48 dBroll off) using Audacity:
2. Noise removal:

The noise profiles and parameter values chosen are mentioned later. For details on how to use Audacity Noise Removal, check this page: <https://manual.audacityteam.org/man/noise_reduction.html>

For AG and CC, ANR only worked the best. For SCh, all three were similar. So for Durham singers, we used ANR only, to not risk losing the vocals because of Spleeter.

So for Durham singers, the pipeline is:

1. Filtering using a lowpass filter of 2400 Hz cutoff and 48 dB roll-off (in Audacity: Effects → EQ and Filters → Low-pass filter) For steps 2 and 3: (Effects → Noise Reduction and Repair → Noise Reduction)
2. Choose noise profile: (note: noise profile is chosen after filtering, not before)
3. Noise removal

Based on trial-error and tuning the parameters, the noise profiles and parameters chosen finally, for the Durham singers were: 

| **Singer** | **Noise Reduction (dB)** | **Sensitivity** | **Frequency smoothing (bands)** | **Noise Profile (for ragas except Bageshri)** | **Noise profile (for Bageshri)\*** |
|------------|---------------------------|-----------------|----------------------------------|-----------------------------------------------|----------------------------------|
| AG         | 12                        | 4               | 0                                | AG_Aalap2_MM – 0 to 4.6s                      | AG_Aalap2_Bag – 0 to 2.9s        |
| CC         | 18                        | 4               | 0                                | CC_Aalap2_Bahar – 0 to 4.8s                   | CC_Aalap1_Bag – 0 to 5.2s        |
| SCh        | 12                        | 4               | 0                                | SCh_Aalap1_Shree – 0 to 4.5s                  | SCh_Aalap2_Bag – 3 min 7.0 s to 3 min 12.3 s |


\* The reason for using different noise profiles for Bageshri was that in Bageshri the tanpura is played in cycles of Sa-Ma instead of Sa-Pa. Hence, the spectra of tanpura in raga Bageshri is different than those in other ragas.

Using this, we got the source-separated audios, which are stored in the folder Source\_Separated\_Audios under two subfolders:

- Old\_Singers\_ANR: Durham singer audios separated using Audacity Noise Removal
- New\_Singers\_Spleeter: Pune singer audios separated using Spleeter

### Part 2: From Source Separated Audio to Pitch Contours

Once we have the source-separated audio, we use the Python API for Praat software, namely [Parselmouth](https://parselmouth.readthedocs.io/en/stable/), to derive the pitch contour from the audio using filtered autocorrelation method. Parselmouth pitch detector has several parameters that can be tuned for increased accuracy of the pitch contour. Based on extraction performance and comparison with the audio done by manual listening to the sonified contour, we found that the following values (see table) worked best on our audio. The tonic is fixed for a given singer, the other parameters are tuned. The tuning was done mainly to avoid octave errors and false silences (regions which are actually voiced but predicted wrongly as silences).



|**Singer**|**Pitch Min (Hz)**|**Tonic**|**Pitch Max (Hz)**|**Silence Threshold**|**Voicing Threshold**|**Octave Cost**|**Octave Jump Cost**|**Voiced/Unvoiced Cost**|
| - | - | - | - | :- | :- | :- | :- | :- |
|(Praat Standard)|50|**-**|800|0\.09|0\.50|0\.055|0\.35|0\.14|
|AK/MP/ NM/MG|80|**146.8**|600|0\.001|0\.01|0\.01|20|10|
|CC|70|**138.6**|560|0\.01|0\.01|0\.1|20|10|
|AG|125|**207.7**|880|0\.01|0\.01|0\.1|10|10|
|SCh|150|**246.9**|900|0\.001|0\.01|0\.1|10|10|
|SS|150|**220.0**|800|0\.01|0\.001|0\.1|20|10|
|SM/RV/AP|150|**220.0**|800|0\.0001|0\.0001|0\.1|20|10|

Attenuation at ceiling: 0.03 for all

The main steps in pitch extraction were:

1) Parselmouth pitch extraction at 10 ms intervals on source-separated audio using the above parameter values
1) Linear Interpolation of silences less than 400 ms

The code for these steps is present in the file extract\_pitch\_contours.py

Instructions to run the script:

1) In the file extract\_pitch\_contours.py, change the variables INPUT\_FOLDER, OUTPUT\_FOLDER and FILE according to your directory structure. INPUT\_FOLDER should contain the audio file that is to be pitch-extracted, and OUTPUT\_FOLDER should be a folder where the csv file of pitch contour is to be stored.
2) Run the script using the command:
   ```
   python extract\_pitch\_contours.py
   ```
The interpolated pitch contour will be saved as a csv file in OUTPUT\_FOLDER

## Video Time Series Processing

### Part 1: From keypoints to time series

1. We use OpenPose with front view camera only for 2D keypoint estimation and VideoPose3D with 3D keypoint estimation. This repository uses the output of OpenPose / VideoPose3D on the videos as input to the processing. VideoPose3D processing utilises the Detectron 2D output of each of the 3 camera views to obtain 3D coordinates with reference to the front view. The data of 3D keypoints is therefore at the video frame rate (25 FPS for Durham singers, 24 FPS for Pune Singers).

   Note:  The different models do not have the same keypoints - this is shown in the columns "OpenPose (2D)" and "VideoPose3D" in the table below where "Y" indicates the keypoint (2D position) available in the corresponding model. In addition, the pre-trained model for VideoPose3D computes the depth for a subset of keypoints only. These are marked as "Y" in the column "VideoPose3D - has depth"

| KeypointName | OpenPose (2D) | VideoPose3D | VideoPose3D - has depth |
|--------------|---------------|-------------|------------------------|
| Nose         | Y             | Y           | N                      |
| Neck         | Y             | N           | N                      |
| RShoulder    | Y             | Y           | Y                      |
| RElbow       | Y             | Y           | Y                      |
| RWrist       | Y             | Y           | Y                      |
| LShoulder    | Y             | Y           | Y                      |
| LElbow       | Y             | Y           | Y                      |
| LWrist       | Y             | Y           | Y                      |
| MidHip       | Y             | N           | N                      |
| RHip         | Y             | Y           | Y                      |
| RKnee        | Y             | Y           | Y                      |
| RAnkle       | Y             | Y           | Y                      |
| LHip         | Y             | Y           | Y                      |
| LKnee        | Y             | Y           | Y                      |
| LAnkle       | Y             | Y           | Y                      |
| REye         | Y             | Y           | N                      |
| LEye         | Y             | Y           | N                      |
| REar         | Y             | Y           | N                      |
| LEar         | Y             | Y           | N                      |
| LBigToe      | Y             | N           | N                      |
| LSmallToe    | Y             | N           | N                      |
| LHeel        | Y             | N           | N                      |
| RBigToe      | Y             | N           | N                      |
| RSmallToe    | Y             | N           | N                      |
| RHeel        | Y             | N           | N                      |

2. We process the data and convert it to a time series for each of the key points.
3. Nulls in data (based on rejecting keypoints with confidence <0.3) are interpolated using linear interpolation.
4. For low-pass filtering, we use the Savitzky Golay (SavGol) filter. The window length of the filter is chosen to be 13 and the polynomial order to be 4.
5. Resampling – the time series was resampled at 10ms using scipy.signal.resample which is an FFT-based resampling algorithm
6. For each keypoint z-score normalization ($\frac{p -\mu}{\sigma}$) was done for the position $p$ per axis ($x,y,z$) using the mean $\mu$ and standard deviation $\sigma$ for that keypoint and axis across the entire recording. Z-score normalization was chosen since we want to retain the direction of motion concerning the mean position of the key point. Thus a positive z-score on the x-axis indicates a position to the right of the mean position and a negative z-score indicates a position to the left of the mean position. Similarly, a positive z-score on the y-axis indicates a position lower than the mean position whilst a negative z-score indicates a position above the mean position. For the z-axis, a positive score means towards the camera and a negative score means away from the front-facing camera.

### Part 2: Velocity and Acceleration Estimation

We discuss here how we estimate the velocities and acceleration profiles of the joints of interest using the extracted keypoints from OpenPose or VideoPose3D. A smoothened derivative is computed on the 2D / 3D joint position time series using convolution with a biphasic filter. We choose a smoothened derivative with controllable smoothing parameters to be able to control the velocity and acceleration profiles. We find that using a 101-point filter achieves a lowpass filtering of about 2 Hz, giving a sufficiently smooth and physiologically plausible movement acceleration profile. 

![image](https://github.com/sujoyrc/hindustani_raga_dataset_processing/assets/8533584/be669afe-b153-47a0-9cd3-aaacaaaaba5b)

The biphasic filter is defined by

![image](https://github.com/sujoyrc/hindustani_raga_dataset_processing/assets/8533584/557a1e54-0efd-4621-b7e2-b2c2888e658f)


We convolve the biphasic filter for differentiation of the position coordinates along each axis $(x,y,z)$ for each joint to obtain the velocity for that joint. We also compute the magnitude of the velocity vector from the individual components. 
We note that convolution using the biphasic filter $h[n]$ defined above gives a negative value with respect to actual change - for example an increase in the values of $p_x[n]$ gives a negative value of $v_x[n]$. However, since we are using the absolute value of the velocity and acceleration, there is no impact on the final result.
We take the Euclidean norm of the individual components of velocity and refer to $v[n]$ as velocity for the joint in the rest of the work. 

![image](https://github.com/sujoyrc/hindustani_raga_dataset_processing/assets/8533584/9039406d-6549-47e8-b55f-5ce5a3c8d1ef)


where $p_x[n]$, $p_y[n]$ and $p_z[n]$ are the position coordinates of the corresponding joint along $x$, $y$ and $z$ axes respectively and $*$ denotes the convolution operation. To prevent any artefacts from the differentiation operation, the position of each keypoint is extrapolated for 102 timesteps (one more than the filter length) before and after the time series by the starting and ending values respectively. This is under the assumption that these are the rest positions of the keypoint. 

We use the same biphasic filter for differentiation of the velocity along each axis to obtain the acceleration along that axis as well as compute the magnitude of the acceleration vector.
We take the Euclidean norm of the individual components of acceleration and refer to $a[n]$ as acceleration for the joint in the rest of the work.

![image](https://github.com/sujoyrc/hindustani_raga_dataset_processing/assets/8533584/4e078b20-ac0c-4e3c-967d-1cdfe3772aa3)


## Using processed master files

If you wish to access directly the final processed master files - one per singer - please download the master files from [OSF Project](https://osf.io/qjkzs/files/osfstorage?view_only=). Choose either 03_master_files_2d or 04_master_files_3d folder as per your requirement.

Below is a sample of the master file. Only columns for right wrist are shown here. There would be similar columns for left wrist and both elbows.

|**filename**|**time**|**pitch**|**RWrist\_x**|**RWrist\_y**|**RWrist\_z**|**RWrist\_vel \_x**|**RWrist\_v el\_y**|**RWrist\_vel \_z**|**RWrist\_v el\_3d**|**RWrist\_ac cl\_x**|**RWrist\_a ccl\_y**|**RWrist\_accl \_z**|**RWrist\_a ccl\_3d**|
| - | - | - | - | - | - | -: | -: | -: | -: | -: | -: | -: | -: |
|AK\_Pakad\_Bag|1|-177|-0.021913|0\.26221|-1.60311|-3.37435|2\.05219|-4.45986|5\.95719|-8.6343|2\.04601|0\.617001|8\.89483|
|AK\_Pakad\_Bag|1\.01|-177.75|-0.004615|0\.24789|-1.56985|-3.29045|2\.02823|-4.44106|5\.88759|-8.90824|2\.0324|-0.399558|9\.14588|
|AK\_Pakad\_Bag|1\.02|-178.5|0\.012233|0\.235822|-1.5374|-3.2057|2\.00511|-4.41154|5\.81022|-9.15283|2\.01253|-1.40199|9\.47576|
|AK\_Pakad\_Bag|1\.03|-179.25|0\.029144|0\.225705|-1.5051|-3.12038|1\.98303|-4.37169|5\.72546|-9.36834|1\.98693|-2.38643|9\.86959|
|AK\_Pakad\_Bag|1\.04|-180|0\.04657|0\.216877|-1.47157|-3.03474|1\.9622|-4.32196|5\.63376|-9.55518|1\.95621|-3.3492|10\.3124|
|AK\_Pakad\_Bag|1\.05|-180.75|0\.064737|0\.208657|-1.43524|-2.94903|1\.94278|-4.26285|5\.53562|-9.71388|1\.92099|-4.28677|10\.7901|
|AK\_Pakad\_Bag|1\.06|-181.5|0\.083529|0\.200628|-1.39519|-2.86346|1\.92492|-4.19491|5\.43158|-9.84505|1\.88193|-5.19583|11\.29|
|AK\_Pakad\_Bag|1\.07|-182.25|0\.102522|0\.192738|-1.35187|-2.77824|1\.90875|-4.11874|5\.32222|-9.94939|1\.8397|-6.07324|11\.8008|
|AK\_Pakad\_Bag|1\.08|-183|0\.121142|0\.185186|-1.30724|-2.69356|1\.89437|-4.03496|5\.20814|-10.0277|1\.79498|-6.91607|12\.313|
|AK\_Pakad\_Bag|1\.09|-186.823|0\.138915|0\.178206|-1.26422|-2.60957|1\.88183|-3.94418|5\.08996|-10.0809|1\.74846|-7.72163|12\.8181|
|AK\_Pakad\_Bag|1\.1|-190.646|0\.155686|0\.171875|-1.22561|-2.52643|1\.87118|-3.84703|4\.96828|-10.1098|1\.70081|-8.48741|13\.3093|

There are two sets of master files provided – one set using the OpenPose based 2D processing and one set using the VideoPose3D based 3D processing.

We provide one master file per singer. The joint names are RWrist, LWrist, RElbow and LElbow for right wrist, left wrist, right elbow, left elbow respectively

The master files have the following columns:-



|**Content**|**No. of cols**|**Column names and Description**|
| - | - | - |
|Filename|1|**filename** `<Singer_Name>_<RecordingType>_<Raga>`e.g. AK\_Pakad\_Bag|
|Time|1|**time** in seconds starting at offset start time|
|Pitch|1|**pitch** in cents|
|Position coordinates|3\*4|**<JointName>\_x, <JointName>\_y, <JointName>\_z** for joint position for each of the joints. \_z values are 0 for the 2D master file|
|Velocity coordinates|3\*4|**<JointName>\_vel\_x, <JointName>\_vel\_y, <JointName>\_vel\_z** for joint velocity for each of the joints. \_z values are 0 for the 2D master file|
|Acceleration coordinates|3\*4|**<JointName>\_accl\_x, <JointName>\_accl\_y, <JointName>\_accl\_z** for joint acceleration for each of the joints. \_z values are 0 for the 2D master file|
|Velocity magnitude|1\*4|**<JointName>\_vel\_mag** for Euclidean magnitude of velocity and acceleration for each of the joints|
|Acceleration magnitude|1\*4|**<JointName>\_accl\_mag** for Euclidean magnitude of velocity and acceleration for each of the joints|
|**Total Numberof columns**|**47**||

**Note:** Position coordinates are z-score normalized over the entire recording. There is no normalization done for velocity and acceleration columns.

## Use in previous work

The initial version of this dataset has been used in 

1. M. Clayton, P. Rao, N. Shikarpur, S. Roychowdhury, and J. Li, “Raga classification from vocal performances using multimodal analysis,” in Proceedings
of the 23rd International Society for Music Information Retrieval Conference,ISMIR, Bengaluru, India, pp. 283-290, 2022.

The full version of this dataset has been used in 

1. S. M. Nadkarni, S. Roychowdhury, P. Rao, and M. Clayton, “Exploring the correspondence of melodic contour with gesture in raga alap singing,” in Proceedings of the 24th International Society for Music Information Retrieval Conference, ISMIR, Milan, Italy 2023

## Replicating the processing of this repository

On the other hand, if you want to download the raw data and replicate our processing, please follow the following steps.

### Before you start

Prepare a virtual environment, cd to the directory where you want to install a python virtual environment:

```
python -m venv .
source bin/activate
```
Download this repository and install the required packages:
```
git clone git@github.com:sujoyrc/hindustani\_raga\_dataset\_processing.git cd hindustani\_raga\_dataset\_processing
pip install -r requirements.txt
```
### Downloading the data

You can download the videos for all singers and all views from [OSF Project - 00_All_Videoes_All_Views](https://osf.io/qjkzs/files/osfstorage?view_only=). Note that you do NOT need the video mp4 files for the rest of the processing in this repository because we provide the pre-processed source separated audio and openpose/videopose output in the following link.

Download the pre-processed audio and video data from [OSF Project](https://osf.io/qjkzs/files/googledrive?view_only=)

Please place the data in the corresponding folders to the corresponding directory here.

| Folder Name               | Directory to be placed in          |
|---------------------------|------------------------------------|
| 01_Source_Separated_Audio | 03_audio_processing_data/01_source_separated_audio |
| 05_openpose_output        | 01_openpose_output                     |
| 06_videopose_output       | 01_videopose_output               |

You need to use EITHER the openpose output **OR** the videopose output depending on the setting in the next step.

### Data Processing

1\. Run the following. Set the CAMERA\_VIEWS variable to be '2D' or '3D'. The default is 3D

```
export ROOT_DIR=`echo $PWD`
export CAMERA_VIEWS=3D
```

**If you are processing with CAMERA\_VIEWS=2D then follow the steps 2a**:-

2a. Download the files into 01_openpose_output
*Alternatively*, create the Openpose json files using the instructions for

[Openpose Installation ](https://github.com/CMU-Perceptual-Computing-Lab/openpose#installation)
[Openpose Quick Start Overview](https://github.com/CMU-Perceptual-Computing-Lab/openpose#quick-start-overview)

**If you are processing with CAMERA\_VIEWS=3D then follow the steps 2b**:-

2b. Download the files into 01_videopose_output

*Alternatively*, create the 3D output for VideoPose3D by following the instructions in [VideoPose3D: Inference in the Wild.](https://github.com/facebookresearch/VideoPose3D/blob/main/INFERENCE.md) Note that each recording with the detections of 3 views should be made into a separate custom dataset. 

3.  **Audio processing** - Instructions to run the pitch contour extraction script:

- Place the source separated audio in 00_data/01_source_separated_audio
- Run the script using the command:
```
cd ${ROOT_DIR}/02_audio_processing
./process_audio.sh
```

Ensure the .sh files have execute (+x) permission for user in question.

The output of this process will create the pitch contours in cents at 10 ms intervals. Unvoiced segments less than 400 ms are interpolated by a linear interpolation. Conversion from Hz to cents is done based on the tonic files in 00\_data/03\_singer\_specific\_tonic. There will be a separate output csv file for each recording present in 00\_data/00\_orig\_video

4\. **Video Processing** - Run the following. This code will use the CAMERA\_VIEWS variable.

```
cd ${ROOT_DIR}/04_video_processing 
./run_gesture_keypoint_extraction.sh
```

Ensure the .sh files have execute (+x) permission for user in question.

This process will create the gesture coordinates for each keypoint. There are three output folders in this processing:-

1) 00\_keypoints\_non\_normalized - this has one file per recording having all keypoints in pixel coordinates at frame rate
2) 01\_keypoints\_all - this has one file per recording having all keypoints followed by z-score normalization at 10ms intervals
3) 02\_keypoints\_selected - this has one file per recording having only the keypoints for wrist and elbow of both hands at 10ms intervals. This is the only data used in the next step

5\.**Multimodal Processing** - Run the following
```
cd ${ROOT_DIR}/06_multimodal_processing
python process_multimodal_data.py
```

This process does the following:-

1. Computes velocity (V) and acceleration (A) by a 101-point biphasic filter on the position (P) coordinates of keypoints of interest. The document [Velocity and acceleration processing](https://github.com/sujoyrc/hindustani_raga_dataset_processing/blob/main/Vel_and_accln_processing_details.pdf) has the details of the biphasic filter and the velocity and acceleration computation.
2. Using the start and end times (i.e. the offsets) removes gesture information outside start and end time intervals and resets the time for the gesture information to zero corresponding to the start time. Then it combines the pitch and gesture for a certain video information based on the adjusted time.
3. Creates a master file per singer containing the gesture information (P+V+A) aligned with the pitch at 10 ms intervals.
