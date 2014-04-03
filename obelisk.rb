require 'formula'

class Obelisk < Formula
  homepage 'https://github.com/spesmilo/obelisk'
  url 'https://github.com/spesmilo/obelisk.git', :tag => 'v1.0'
  head 'https://github.com/spesmilo/obelisk.git', :branch => 'master'

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'homebrew/versions/gcc48' => :build
  depends_on 'libtool' => :build
  depends_on 'pkg-config' => :build

  depends_on 'Nevtep/bitcoin/libbitcoin'
  depends_on 'Nevtep/bitcoin/libconfig-gcc48'
  depends_on 'Nevtep/bitcoin/zeromq2-gcc48'

  def install
    ENV.prepend_path 'PATH', "#{HOMEBREW_PREFIX}/opt/gcc48/bin"
    ENV['CC'] = "gcc-4.8"
    ENV['CXX'] = ENV['LD'] = "g++-4.8"
    ENV.cxx11

    # I thought depends_on libbitcoin would be enough, but I guess not...
    libbitcoin = Formula.factory('Nevtep/bitcoin/libbitcoin')
    ENV.append 'CPPFLAGS', "-I#{libbitcoin.include}"
    ENV.append 'LDFLAGS', "-L#{libbitcoin.lib}"

    # I thought depends_on libconfig-gcc48 would be enough, but I guess not...
    libconfiggcc48 = Formula.factory('Nevtep/bitcoin/libconfig-gcc48')
    ENV.append 'CPPFLAGS', "-I#{libconfiggcc48.include}"
    ENV.append 'LDFLAGS', "-L#{libconfiggcc48.lib}"

    # I thought depends_on zermoq-gcc48 would be enough, but I guess not...
    zeromq2gcc48 = Formula.factory('Nevtep/bitcoin/zeromq2-gcc48')
    ENV.append 'CPPFLAGS', "-I#{zeromq2gcc48.include}"
    ENV.append 'LDFLAGS', "-L#{zeromq2gcc48.lib}"

    system "autoreconf", "-i"
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--sysconfdir=#{etc}"

    system "make", "install"
  end

  test do
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test obelisk`.
    system "false"
  end
end
