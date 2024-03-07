FROM nvidia/cudagl:11.1.1-base-ubuntu18.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

#Install basic linux packages
RUN apt-get update \
    && apt-get install -y build-essential \
    && apt-get install -y wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

RUN apt-get update && apt-get install -y curl
# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda

#Set up conda env with python=3.6 installed
ENV PATH=$CONDA_DIR/bin:$PATH
RUN conda create -y -n env0 python=3.6
RUN conda init 
ENV PATH=/opt/conda/envs/env0/bin:$PATH    

# Minimal setup
RUN apt-get update \
 && apt-get install -y locales lsb-release
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg-reconfigure locales
 
# Install ROS Melodic

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' 
RUN curl -k https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add -

RUN apt-get update -q && \
    apt-get install -y ros-melodic-desktop-full python-rosdep &&\
    apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-tools python3-vcstool &&\
    rm -rf /var/lib/apt/lists/*

RUN rosdep init \
 && rosdep fix-permissions \
 && rosdep update
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN source /opt/ros/melodic/setup.bash && catkin_init_workspace 
RUN apt-get update && apt-get install -y --no-install-recommends \
   cmake \
   libzmqpp-dev \
   libopencv-dev 

#Gazebo Install
RUN apt-get install -y ros-melodic-gazebo-ros-pkgs ros-melodic-gazebo-ros-control

#Flightmare install
RUN sudo apt-get install -y libgoogle-glog-dev 
RUN sudo apt-get install -y protobuf-compiler 
RUN sudo apt-get install -y ros-melodic-octomap-msgs 
RUN sudo apt-get install -y ros-melodic-octomap-ros 
RUN sudo apt-get install -y ros-melodic-joy python3-vcstool
RUN sudo apt-get install -y python3-pip 
RUN pip install catkin-tools
RUN pip install tensorflow-gpu==1.14.0
RUN pip install scikit-build
RUN sudo apt-get install -y ros-melodic-catkin python3-catkin-tools 
RUN cd && mkdir -p catkin_ws/src && cd catkin_ws 
RUN catkin config --init --mkdirs --extend /opt/ros/melodic --merge-devel --cmake-args -DCMAKE_BUILD_TYPE=Release
RUN sudo apt-get install -y libgazebo9 gazebo9-common gazebo9-plugin-base gazebo9

#Set up git
RUN sudo apt-get install -y git
RUN mkdir /root/.ssh/
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN cd ~/catkin_ws/src && git clone https://github.com/workoapbl/flightsim.git
RUN cd ~/catkin_ws/src && vcs-import < flightsim/flightros/dependencies.yaml

RUN source /opt/ros/melodic/setup.bash && cd ~/catkin_ws/src && catkin_init_workspace
RUN source /opt/ros/melodic/setup.bash && cd ~/catkin_ws && catkin_make
RUN catkin build

SHELL ["/bin/bash", "-c"]
RUN echo "source ~/catkin_ws/devel/setup.bash" >> /root/.bashrc && \
   echo "export FLIGHTMARE_PATH=~/catkin_ws/src/flightmare" >> /root/.bashrc && \
   source /root/.bashrc

WORKDIR /home/user/fm

EXPOSE 8000
