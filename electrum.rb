require 'formula'

class Electrum < Formula
  homepage 'http://electrum.org/'
  url 'https://github.com/spesmilo/electrum.git', :tag => '1.9.8'
  head 'https://github.com/spesmilo/electrum.git', :branch => 'master'

  depends_on 'ecdsa' => :python
  depends_on 'pycurl' => :python
  #depends_on 'slowaes' => :python  # must be installed with pip install --pre slowaes
  depends_on 'qt'
  depends_on 'pyqt'
  depends_on 'gettext'

  def install
        system "python", "mki18n.py"
        system "pyrcc4", "icons.qrc", "-o", "gui/qt/icons_rc.py"
        system 'ARCHFLAGS="-arch i386 -arch x86_64" python setup-release.py py2app --includes sip'

        cd 'dist' do
            prefix.install "Electrum.app"
        end
  end

  test do
	system "false"
  end

  def caveats
    "You must also run `pip install --pre slowaes`"
  end

end

__END__
