require 'formula'

class CzmqppGcc48 < Formula
  homepage 'https://github.com/zeromq/czmqpp'
  url 'https://github.com/zeromq/czmqpp.git', :branch => 'master' 
  
  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'homebrew/versions/gcc48' => :build
  depends_on 'libtool' => :build
  depends_on 'pkg-config' => :build

  depends_on 'Nevtep/bitcoin/zeromq2-gcc48'

  def install
    # ENV.prepend_path 'PATH', "#{HOMEBREW_PREFIX}/opt/gcc48/bin"
    # ENV['CC'] = "gcc-4.8"
    # ENV['CXX'] = ENV['LD'] = "g++-4.8"
    # ENV.cxx11

    # I thought depends_on zermoq-gcc48 would be enough, but I guess not...
    # zeromq2gcc48 = Formula.factory('Nevtep/bitcoin/zeromq2-gcc48')
    # ENV.append 'CPPFLAGS', "-I#{zeromq2gcc48.include}"
    # ENV.append 'LDFLAGS', "-L#{zeromq2gcc48.lib}"

    # ENV.cxx11

    system "autoreconf", "-i"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--sysconfdir=#{etc}"
    system "make"
    system "make", "install"
    system "ldconfig"
  end

  test do
    system "false"
  end
end
