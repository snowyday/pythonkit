FROM snowyday/barekit:latest
MAINTAINER snowyday

# User
ENV USER user
ENV PASS user

USER $USER
WORKDIR /home/$USER

# Set anaconda version
ENV ANACONDA anaconda3-2019.10
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

# Python libs
## conda
RUN conda install -y pytorch torchvision cudatoolkit=9.0 -c pytorch

## pip
RUN pip install tqdm dill lifelines Xgboost ipdb parmap gym pyarrow hiredis plotly==4.4.1 umap-learn
RUN pip install git+https://github.com/hyperopt/hyperopt.git

## clear
RUN conda clean --all -y

# Jupyter
RUN jupyter notebook --generate-config \
    && echo ''c.NotebookApp.token = \"$PASS\"'' >> $HOME/.jupyter/jupyter_notebook_config.py \
    && echo ''c.NotebookApp.ip = \"0.0.0.0\"'' >> $HOME/.jupyter/jupyter_notebook_config.py

# ENV export
RUN echo "export PYENV_ROOT=/home/$USER/.pyenv" >> ~/.zshrc
RUN echo "export PATH=$PYENV_ROOT/bin:$PYENV_ROOT/shims:\$PATH" >> ~/.zshrc
RUN echo "export DYLD_FALLBACK_LIBRARY_PATH=$PYENV_ROOT/versions/$ANACONDA/lib" >> ~/.zshrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# SSH start
USER root
CMD ["/usr/sbin/sshd", "-D"]
