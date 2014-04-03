require 'formula'

class Sx < Formula
  homepage 'https://github.com/spesmilo/sx'
  url 'https://github.com/spesmilo/sx.git', :tag => 'v1.0'
  head 'https://github.com/spesmilo/sx.git', :branch => 'master'

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libtool' => :build
  depends_on 'pkg-config' => :build

  depends_on 'qrencode' => :recommended
  depends_on 'Nevtep/bitcoin/boost-gcc48' => 'c++11'
  depends_on 'Nevtep/bitcoin/libwallet'
  depends_on 'Nevtep/bitcoin/libbitcoin'
  depends_on 'Nevtep/bitcoin/libconfig-gcc48'
  depends_on 'Nevtep/bitcoin/zeromq2-gcc48'
  depends_on 'Nevtep/bitcoin/obelisk'

  def install
    ENV.prepend_path 'PATH', "#{HOMEBREW_PREFIX}/opt/gcc48/bin"
    ENV['CC'] = "gcc-4.8"
    ENV['CXX'] = ENV['LD'] = "g++-4.8"
    ENV.cxx11

    # I thought depends_on boost-gcc48 would be enough, but I guess not...
    boostgcc48 = Formula.factory('Nevtep/bitcoin/boost-gcc48')
    ENV.append 'CPPFLAGS', "-I#{boostgcc48.include}"
    ENV.append 'LDFLAGS', "-L#{boostgcc48.lib}"

    # I thought depends_on libconfig-gcc48 would be enough, but I guess not...
    libconfiggcc48 = Formula.factory('Nevtep/bitcoin/libconfig-gcc48')
    ENV.append 'CPPFLAGS', "-I#{libconfiggcc48.include}"
    ENV.append 'LDFLAGS', "-L#{libconfiggcc48.lib}"

    # I thought depends_on leveldb-gcc48 would be enough, but I guess not...
    leveldbgcc48 = Formula.factory('Nevtep/bitcoin/leveldb-gcc48')
    ENV.append 'CPPFLAGS', "-I#{leveldbgcc48.include}"
    ENV.append 'LDFLAGS', "-L#{leveldbgcc48.lib}"

    # I thought depends_on zermoq-gcc48 would be enough, but I guess not...
    zeromq2gcc48 = Formula.factory('Nevtep/bitcoin/zeromq2-gcc48')
    ENV.append 'CPPFLAGS', "-I#{zeromq2gcc48.include}"
    ENV.append 'LDFLAGS', "-L#{zeromq2gcc48.lib}"
    
    libwallet = Formula.factory('Nevtep/bitcoin/libwallet')
    ENV.append 'libwallet_CFLAGS', "-I#{libwallet.include}"
    ENV.append 'libwallet_LIBS', "-L#{libwallet.lib}"

    libbitcoin = Formula.factory('Nevtep/bitcoin/libbitcoin')
    ENV.append 'libbitcoin_CFLAGS', "-I#{libbitcoin.include}"
    ENV.append 'libbitcoin_LIBS', "-L#{libbitcoin.lib}"

    ENV.append 'libbitcoin_LIBS', "-lbitcoin -lpthread -lleveldb -lcurl -lboost_thread-mt -lboost_regex -lboost_filesystem -lboost_system -lobelisk -lwallet"

    ENV.cxx11

    system "autoreconf", "-i"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--sysconfdir=#{etc}"
    system "make"
    system "make", "install"
  end

  test do
    system "false"
  end
end
