require 'formula'

class BitcoindNextTest < Formula
  homepage 'http://bitcoin.org/'
  head 'https://github.com/luke-jr/bitcoin.git', :branch => 'next-test'

  keg_only "conflicts with Nevtep/bitcoin/bitcoind"

  depends_on 'boost'
  depends_on 'berkeley-db4'
  depends_on 'miniupnpc' if build.include? 'with-upnp'

  option 'with-upnp', 'Compile with UPnP support'
  option 'without-ipv6', 'Compile without IPv6 support'

  def install
    cd "src" do
      system "make", "-f", "makefile.osx",
        "DEPSDIR=#{HOMEBREW_PREFIX}",
        "USE_UPNP=#{(build.include? 'with-upnp') ? '1' : '-'}",
        "USE_IPV6=#{(build.include? 'without-ipv6') ? '-' : '1'}"
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
