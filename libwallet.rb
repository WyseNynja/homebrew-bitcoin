require 'formula'

class Libwallet < Formula
  homepage 'https://github.com/spesmilo/libwallet'
  url 'https://github.com/spesmilo/libwallet.git', :tag => 'v0.4'
  head 'https://github.com/spesmilo/libwallet.git', :branch => 'master'

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'homebrew/versions/gcc48' => :build
  depends_on 'libtool' => :build
  depends_on 'pkg-config' => :build

  depends_on 'curl'  # todo: should this use gcc48?
  depends_on 'openssl'  # todo: should this use gcc48?
  depends_on 'WyseNynja/bitcoin/boost-gcc48' => 'c++11'
  depends_on 'WyseNynja/bitcoin/leveldb-gcc48'  # todo: make this optional

  option 'enable-testnet', "Enable testnet"
  option 'enable-debug', "Enable debug"

  def install
    ENV.prepend_path 'PATH', "#{HOMEBREW_PREFIX}/opt/gcc48/bin"
    ENV['CC'] = "gcc-4.8"
    ENV['CXX'] = ENV['LD'] = "g++-4.8"
    ENV.cxx11

    # I thought depends_on libbitcoin would be enough, but I guess not...
    libbitcoin = Formula.factory('WyseNynja/bitcoin/libbitcoin')
    ENV.append 'libbitcoin_CFLAGS', "-I#{libbitcoin.include}"
    ENV.append 'libbitcoin_LIBS', "-L#{libbitcoin.lib}"

    args =     ["--disable-dependency-tracking",
            "--prefix=#{prefix}"]

    system "autoreconf", "-i"
    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test libbitcoin`.
    system "false"
  end
end

__END__
