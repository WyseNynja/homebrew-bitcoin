require 'formula'

class ArmoryQt < Formula
  homepage 'http://bitcoinarmory.com/'
  url 'https://github.com/etotheipi/BitcoinArmory.git', :tag => 'v0.90-beta'
  version '0.90-beta'

  devel do
    url 'https://github.com/etotheipi/BitcoinArmory.git', :branch => '0.91-dev'
    version '0.91-dev'
  end

  option 'codesign-app', 'Codesign ArmoryQt.app (untested)'
  option 'with-app', 'Build ArmoryQt.app (untested)'

  depends_on 'cryptopp'
  depends_on 'libpng'
  depends_on :python => 'psutil' if build.without? 'app'
  depends_on 'pyqt'
  depends_on :python
  depends_on 'sip'
  depends_on 'swig'
  depends_on :python => 'twisted' if build.without? 'app'
  depends_on :xcode if build.include? 'codesign-app'

  # brew uses it's own PATH during installs, so a custom installed gpg (like from GPGTools) won't be found
  depends_on 'gpg' => :recommended

  def patches
    DATA
  end

  def install
    if not build.devel? and not build.head? and not build.without? 'gpg'
      cd "#{cached_download}" do
        # prefix version with a "v" to match tags
        system "git verify-tag v#{version}"
      end
    end

    ENV.j1  # if your formula's build system can't parallelize

    if build.with? 'app'
      system "make osx"
      cd "osxbuild" do
        prefix.install "Armory.app"
      end
    else
      system "make"
      # todo: these directories change with v0.90
      system "mkdir -p #{share}/armory/img"
      system "mkdir -p #{share}/armory/extras"
      system "mkdir -p #{share}/armory/jsonrpc"
      system "cp *.py *.so README LICENSE #{share}/armory/"
      system "cp img/* #{share}/armory/img"
      system "cp extras/*.py #{share}/armory/extras"
      system "cp jsonrpc/*.py #{share}/armory/jsonrpc"
      bin.install 'ArmoryQt.command'
    end
  end

  def caveats
    if build.with? 'app'
      <<-EOS
      ArmoryQt.app was installed in:
        #{prefix}

      To symlink into ~/Applications, you can do:
        brew linkapps

      You will need bitcoin-qt or bitcoind running if you want to go online.
      EOS
    else
      <<-EOS.undent
      ArmoryQt.command was installed in
        #{bin}

      To symlink into ~/Applications, you can do:
        ln -s #{bin}/ArmoryQt.command ~/Applications/ArmoryQt

      Or you can just run 'ArmoryQt.command' from your terminal

      You will need bitcoin-qt or bitcoind running if you want to go online.
      EOS
    end
  end
end

__END__
diff --git a/ArmoryQt.command b/ArmoryQt.command
new file mode 100644
index 0000000..2cc2154
--- /dev/null
+++ b/ArmoryQt.command
@@ -0,0 +1,3 @@
+#!/bin/sh
+PYTHONPATH=`brew --prefix`/lib/python2.7/site-packages /usr/bin/python `brew --prefix`/share/armory/ArmoryQt.py $@
+
diff --git a/osxbuild/deploy.sh b/osxbuild/deploy.sh
index de3e31b..11b6975 100755
--- a/osxbuild/deploy.sh
+++ b/osxbuild/deploy.sh
@@ -14,15 +14,12 @@ function get_dependencies()
 {
     # get build dependencies
     echo "Installing dependencies..."
-    brew install cryptopp swig qt pyqt wget
-    sudo pip install virtualenv 
-    sudo pip install psutil
 }
 
 function make_env()
 {
     echo "Making python environment..."
-    virtualenv -q env
+    virtualenv -p /usr/bin/python -q env
     cd env
     bin/pip install twisted >/dev/null
     bin/pip install psutil 
