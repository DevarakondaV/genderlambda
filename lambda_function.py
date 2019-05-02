#Set working directory to local tmp
import os
import sys
import base64
os.chdir("/tmp")
HERE = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(HERE,"packs"))

import zipfile
import json
import boto3
import time


def load_model_from_s3():

  ##check if model exists
  if not os.path.isfile("genderMv79.h5"):
    print("Model does not exist, Loading Model")
    s3 = boto3.client('s3')

    t1 = time.time()
    with open('genderMv79.h5','wb') as f:
        s3.download_fileobj('gendermodel','genderMv79.h5',f)
    print("Model Load Time", time.time()-t1)
  else :
    print("Model exists")
  return

def load_env_s3():
  if not os.path.isfile("packs.zip"):
    print("Packs do not exist", "Loading packs")
    s3 = boto3.client('s3')
    # Load file into temp folder
    t1 = time.time()
    with open('packs.zip','wb') as f:  
      s3.download_fileobj('gendermodel','packs.zip',f)
    print("Zip load time", time.time()-t1)
  else:
    print("Packs exist")
  return

def unzip_files():
  
  #Extracts packs in zip file
  if not os.path.isdir("tmp/packs/"):
    print("Unzipped Packs don't exist", "Unzipping")
    t1 = time.time()
    zfile = zipfile.ZipFile('packs.zip','r')
    zfile.extractall("tmp/packs/")
    zfile.close()   
    print("File extraction time", time.time()-t1) 
  else:
    print("packs unzipped")
  return


def lambda_handler(event, context):


    #Check for files and load if not available
    load_env_s3()
    unzip_files()

    #Assign new path for python packages
    sys.path.insert(0,'tmp/packs')
    #import h5py
    import tensorflow as tf
    import numpy as np

    load_model_from_s3()

    print('Loading Model....')
    model = tf.keras.models.load_model("genderMv79.h5")
    img = json.loads(event['body'])['payload']
    image = np.array(img)
    prediction = model.predict(image)
    print("Prediction",prediction)



    return {
      'statusCode': 200,
      'body': json.dumps('Hello for lamba!')
    }