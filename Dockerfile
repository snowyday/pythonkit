FROM snowyday/barekit:latest
MAINTAINER snowyday

# Set user
ENV USER user
USER $USER
WORKDIR /home/$USER

# Set anaconda version
ENV ANACONDA anaconda3-5.3.1
ENV HOME /home/$USER
ENV PATH /home/$USER/.pyenv/bin:/opt/pyenv/shims:$PATH
ENV PYENV_ROOT /home/$USER/.pyenv
ENV PATH $PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH
ENV DYLD_FALLBACK_LIBRARY_PATH $PYENV_ROOT/versions/$ANACONDA/lib 

# Pyenv
RUN git clone https://github.com/yyuu/pyenv.git ~/.pyenv
RUN git clone git://github.com/yyuu/pyenv-update.git ~/.pyenv/plugins/pyenv-update

# Anaconda
RUN pyenv install $ANACONDA
RUN pyenv global $ANACONDA
RUN conda update --all -y && conda clean --all -y

# Python libs
## conda
RUN conda install -y sas7bdat
RUN conda install -y pytorch torchvision -c pytorch

## pip
RUN pip install tqdm dill lifelines xgboost
RUN pip install git+https://github.com/hyperopt/hyperopt.git

## for 'collections.abc' is deprecated, and in 3.8 it will stop working
RUN conda upgrade scikit-learn -y

## clear
RUN conda clean --all -y

# Jupyter
RUN jupyter notebook --generate-config \
    && echo ''c.NotebookApp.token = \"user\"'' >> $HOME/.jupyter/jupyter_notebook_config.py

# ENV export
RUN echo "export PYENV_ROOT=/home/$USER/.pyenv" >> ~/.zshrc
RUN echo "export PATH=$PYENV_ROOT/bin:$PYENV_ROOT/shims:\$PATH" >> ~/.zshrc
RUN echo "export DYLD_FALLBACK_LIBRARY_PATH=$PYENV_ROOT/versions/$ANACONDA/lib" >> ~/.zshrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Set root for sshd
USER root
