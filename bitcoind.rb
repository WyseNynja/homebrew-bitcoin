require 'formula'

class Bitcoind < Formula
  homepage 'http://bitcoin.org/'
  head 'https://github.com/bitcoin/bitcoin.git'
  url 'https://github.com/bitcoin/bitcoin.git', :tag => 'v0.8.3'
  version '0.8.3'

  devel do
    url 'https://github.com/bitcoin/bitcoin.git', :branch => 'master'
    version 'master'
  end

  depends_on 'boost'
  depends_on 'berkeley-db4'
  depends_on 'miniupnpc' if build.include? 'with-upnp'

  option 'with-upnp', 'Compile with UPnP support'
  option 'without-ipv6', 'Compile without IPv6 support'

  def patches
    # fixes berkeley-db4 include and lib path
    DATA
  end

  def install
    cd "src" do
      system "make", "-f", "makefile.osx",
        "DEPSDIR=#{HOMEBREW_PREFIX}",
        "USE_UPNP=#{(build.include? 'with-upnp') ? '1' : '-'}",
        "USE_IPV6=#{(build.include? 'without-ipv6') ? '-' : '1'}"
      system "strip bitcoind"
      bin.install "bitcoind"
    end
  end

  def caveats; <<-EOS.undent
    You will need to setup your bitcoin.conf if you haven't already done so:

    echo "rpcuser=user" >> "~/Library/Application Support/Bitcoin/bitcoin.conf"
    echo "rpcpassword=password" >> "~/Library/Application Support/Bitcoin/bitcoin.conf"
    EOS
  end
end
__END__
diff --git a/src/makefile.osx b/src/makefile.osx
index 359739b..7b2f6e2 100644
--- a/src/makefile.osx
+++ b/src/makefile.osx
@@ -13,11 +13,11 @@ INCLUDEPATHS= \
  -I"$(CURDIR)" \
  -I"$(CURDIR)"/obj \
  -I"$(DEPSDIR)/include" \
- -I"$(DEPSDIR)/include/db48"
+ -I"$(DEPSDIR)/opt/berkeley-db4/include"
 
 LIBPATHS= \
  -L"$(DEPSDIR)/lib" \
- -L"$(DEPSDIR)/lib/db48"
+ -L"$(DEPSDIR)/opt/berkeley-db4/lib"
 
 USE_UPNP:=1
 USE_IPV6:=1

