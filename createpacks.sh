# Modified version of ryfeus code
# https://github.com/ryfeus/lambda-packs/blob/master/Tensorflow/buildPack.sh
tall () {
    yum -y update
    yum -y upgrade
    yum install -y \
    wget \
    gcc \
    gcc-c++ \
    python36-devel \
    python36-pip \
    findutils \
    zlib-devel \
    zip

    python3 -m pip install -U virtualenv
}

pip_rasterio () {
    cd /home/
    rm -rf env
    python3 -m virtualenv env --python=python3
    source env/bin/activate
    python3 -m pip install -U pip wheel
    python3 -m pip install numpy -U
    python3 -m pip install tensorflow -U
    deactivate
}


gather_pack () {
    # packing
    cd /home/
    source env/bin/activate

    rm -rf lambdapack
    mkdir lambdapack
    cd lambdapack

    cp -R /home/env/lib/python3.6/site-packages/* .
    cp -R /home/env/lib64/python3.6/site-packages/* .
    cp -R /home/env/lib/python3.6/dist-packages/* .
    cp -R /home/env/lib64/python3.6/dist-packages/* .
    echo "original size $(du -sh /home/lambdapack | cut -f1)"

    # cleaning libs
    rm -rf external
    find . -type d -name "tests" -exec rm -rf {} +

    # cleaning
    find -name "*.so" | xargs strip
    find -name "*.so.*" | xargs strip
    # find . -name tests -type d -print0|xargs -0 rm -r --
    # find . -name test -type d -print0|xargs -0 rm -r --    
    rm -r pip
    rm -r pip-*
    rm -r wheel
    rm -r wheel-*
    rm -r h5py
    rm -r h5py-*
    rm easy_install.py
    find . -name \*.pyc -delete
    # find . -name \*.txt -delete
    echo "stripped size $(du -sh /home/lambdapack | cut -f1)"
    cp -R /home/env/lib/python3.6/site-packages/h5py* .
    cp -R /home/env/lib64/python3.6/site-packages/h5py* .
    cp -R /home/env/lib/python3.6/dist-packages/h5py* .
    cp -R /home/env/lib64/python3.6/dist-packages/h5py* .
 

    # compressing
    zip -FS -r9 ../pack.zip * > /dev/null 
    echo "compressed size $(du -sh ../pack.zip | cut -f1)"
}

main () {
    tall
    pip_rasterio
    gather_pack
}

main
