require 'formula'

class Libbitcoin < Formula
  homepage 'https://github.com/spesmilo/libbitcoin'
  url 'https://github.com/spesmilo/libbitcoin.git', :tag => 'v2.0'
  head 'https://github.com/spesmilo/libbitcoin.git', :branch => 'master'

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'homebrew/versions/gcc48' => :build
  depends_on 'libtool' => :build
  depends_on 'pkg-config' => :build

  depends_on 'curl'  # todo: should this use gcc48?
  depends_on 'openssl'  # todo: should this use gcc48?
  depends_on 'Nevtep/bitcoin/boost-gcc48' => 'c++11'
  depends_on 'Nevtep/bitcoin/leveldb-gcc48'  # todo: make this optional

  option 'enable-testnet', "Enable testnet"
  option 'enable-debug', "Enable debug"

  def patches
    unless build.head?
      # fix include and lib paths for berkeley-db4 and leveldb in the .pc
      # i'm not sure if this is the right way to do this, but it works
      DATA
    end
  end

  def install
    ENV.prepend_path 'PATH', "#{HOMEBREW_PREFIX}/opt/gcc48/bin"
    ENV['CC'] = "gcc-4.8"
    ENV['CXX'] = ENV['LD'] = "g++-4.8"
    ENV.cxx11

    # I thought depends_on boost-gcc48 would be enough, but I guess not...
    boostgcc48 = Formula.factory('Nevtep/bitcoin/boost-gcc48')
    ENV.append 'CPPFLAGS', "-I#{boostgcc48.include}"
    ENV.append 'LDFLAGS', "-L#{boostgcc48.lib}"

    # trickery to get this into the .pc.  what is the right way to do this?
    ENV.append 'EXTRA_CFLAGS', "-I#{boostgcc48.include}"
    ENV.append 'EXTRA_LDFLAGS', "-L#{boostgcc48.lib}"

    # I thought depends_on curl would be enough, but I guess not...
    curl = Formula.factory('curl')
    ENV.append 'CPPFLAGS', "-I#{curl.include}"
    ENV.append 'LDFLAGS', "-L#{curl.lib}"

    # I thought depends_on openssl would be enough, but I guess not...
    openssl = Formula.factory('openssl')
    ENV.append 'CPPFLAGS', "-I#{openssl.include}"
    ENV.append 'LDFLAGS', "-L#{openssl.lib}"

    # I thought depends_on leveldb-gcc48 would be enough, but I guess not...
    leveldbgcc48 = Formula.factory('Nevtep/bitcoin/leveldb-gcc48')
    ENV.append 'CPPFLAGS', "-I#{leveldbgcc48.include}"
    ENV.append 'LDFLAGS', "-L#{leveldbgcc48.lib}"

    # trickery to get this into the .pc.  what is the right way to do this?
    ENV.append 'EXTRA_CFLAGS', "-I#{leveldbgcc48.include}"
    ENV.append 'EXTRA_LDFLAGS', "-L#{leveldbgcc48.lib}"

    args = ["--enable-leveldb",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}"]
    args << "--enable-testnet" if build.include? 'enable-testnet'
    args << "--enable-debug" if build.include? 'enable-debug'

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
diff --git a/configure.ac b/configure.ac
index 5ad6e6d..c07566f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -64,6 +64,9 @@ AC_ARG_WITH([pkgconfigdir], AS_HELP_STRING([--with-pkgconfigdir=PATH],
     [pkgconfigdir="$withval"], [pkgconfigdir='${libdir}/pkgconfig'])
 AC_SUBST([pkgconfigdir])
 
+AC_SUBST(EXTRA_CFLAGS)
+AC_SUBST(EXTRA_LDFLAGS)
+
 AC_CONFIG_FILES([Makefile include/bitcoin/Makefile src/Makefile libbitcoin.pc])
 AC_OUTPUT
 
diff --git a/libbitcoin.pc.in b/libbitcoin.pc.in
index 81880f3..dbb9961 100644
--- a/libbitcoin.pc.in
+++ b/libbitcoin.pc.in
@@ -7,8 +7,6 @@ Name: libbitcoin
 Description:  Rewrite bitcoin, make it super-pluggable, very easy to do and hack everything at every level, and very configurable.
 URL: http://libbitcoin.dyne.org
 Version: @PACKAGE_VERSION@
-Requires: libcurl
-Cflags: -I${includedir} -std=c++11 @CFLAG_LEVELDB@
-Libs: -L${libdir} -lbitcoin -lboost_thread -lboost_system -lboost_regex -lboost_filesystem -lpthread -lcurl @LDFLAG_LEVELDB@
-Libs.private: -lcrypto -ldl -lz
-
+Requires: libcurl, openssl
+Cflags: -I${includedir} @EXTRA_CFLAGS@ -std=c++11 @CFLAG_LEVELDB@
+Libs: -L${libdir} @EXTRA_LDFLAGS@ -lbitcoin -lboost_filesystem -lboost_regex -lboost_system -lboost_thread-mt @LDFLAG_LEVELDB@ -lpthread

diff --git a/src/Makefile.am b/src/Makefile.am
index 754d2f2..798d3e8 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -44,6 +44,7 @@ libbitcoin_la_SOURCES += \
 endif
 
 libbitcoin_la_LIBADD = \
-    -lboost_thread -lboost_system -lboost_regex -lboost_filesystem -lpthread \
+    -lboost_thread-mt -lboost_system -lboost_regex -lboost_filesystem \
+    -lpthread \
     -lcurl @LDFLAG_LEVELDB@ -lcrypto -ldl -lz

