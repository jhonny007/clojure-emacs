from clojure:openjdk-8-lein-stretch as dev

MAINTAINER Christian Gruber <christian.gruber@web.de>

# alpine package
# RUN apk add --no-cache \
    # emacs-x11 \
    # git \
    # grep \
    # diffutils \
    # ctags \
    # tree

RUN apt-get update && \
    apt-get install -y \
    autoconf \
    automake \
    autotools-dev \
    build-essential\
    curl \
    dpkg-dev \
    git \
    gnupg \
    imagemagick \
    ispell \
    libacl1-dev \
    libasound2-dev \
    libcanberra-gtk3-module \
    liblcms2-dev \
    libdbus-1-dev \
    libgif-dev \
    libgnutls28-dev \
    libgpm-dev \
    libgtk-3-dev \
    libwebkit2gtk-4.0-dev \
    libjansson-dev \
    libjpeg-dev \
    liblockfile-dev \
    libm17n-dev \
    libmagick++-6.q16-dev \
    libncurses5-dev \
    libotf-dev \
    libselinux1-dev \
    libtiff-dev \
    libxaw7-dev \
    libxml2-dev \
    openssh-client \
    python \
    texinfo \
    xaw3dg-dev \
    zlib1g-dev \
    tree\
    && rm -rf /val/lib/apt/lists/*

ENV EMACS_BRANCH="emacs-26.3"
ENV EMACS_VERSION="26.3"

RUN wget http://ftp.wrz.de/pub/gnu/emacs/$EMACS_BRANCH.tar.xz
RUN tar xJf $EMACS_BRANCH.tar.xz -C /opt
RUN ln -s /opt/$EMACS_BRANCH /opt/emacs

#COPY EMACS_BRANCH /opt/emacs

RUN cd /opt/emacs && \
    ./autogen.sh && \
    ./configure --with-cairo --with-xwidgets --with-x-toolkit=gtk3 --with-modules && \
    make -j 8 && \
    make install

# Dependency Management with http://github.com/cask/cask
ENV PATH="/root/.cask/bin:$PATH"
RUN curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python


# Checkout emacs configuration from github
RUN git clone \
    --depth 1 \
#    -b use-package \
    https://github.com/jhonny007/emacs-for-clojure.git /code \
    && cd /code \
    && mkdir -p /root/.emacs.d \
    && cp -r elpa /root/.emacs.d \
    && git submodule init \
    && git submodule update

# working with local files
# RUN mkdir /code
# COPY code /code
#
# RUN mkdir -p /root/.emacs.d
# COPY code/elpa /root/.emacs.d/elpa

# copy maven repository with clojure libs
COPY m2 /root/.m2

# Set the `emacs-user-directory` used from the `init.el` file
ENV EMACS_USER_DIRECTORY /code/

# Used to set the proper ctags executable
ENV DOCKER true

WORKDIR /src

CMD sh -c "/etc/init.d/dbus start; emacs --no-site-file --no-splash --load /code/.emacs.docker $FILE_TO_OPEN"
