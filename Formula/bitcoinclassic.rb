class Bitcoinclassic < Formula
  desc "A decentralized, peer to peer payment network"
  homepage "https://bitcoinclassic.com/"
  url "https://github.com/bitcoinclassic/bitcoinclassic/archive/v0.11.2.tar.gz"
  version "0.11.2"
  sha256 "66b4bd52ed8b97e28da46ac552396c40853a9d7f765063603552e1cf118a2227"

  head do
    url "https://github.com/bitcoinclassic/bitcoinclassic.git"

  end

  conflicts_with "bitcoind", :because => "bitcoind also ships a bitcoind binary"
  conflicts_with "bitcoinxt", :because => "bitcoinxt also ships a bitcoind binary"

  option "with-gui", "Build the GUI client (requires Qt5)"

  depends_on :macos => :lion
  depends_on :xcode => :build

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "berkeley-db4"
  depends_on "boost"
  depends_on "libevent"
  depends_on "libtool" => :build
  depends_on "miniupnpc" => :recommended
  depends_on "openssl"
  depends_on "pkg-config" => :build

  if build.with? "gui"
    depends_on "gettext" => :recommended
    depends_on "protobuf"
    depends_on "qrencode"
    depends_on "qt5"
  end

  def install
    args = ["--prefix=#{libexec}", "--disable-dependency-tracking"]

    if build.with? "gui"
      args << "--with-qrencode"
    end

    args << "--without-miniupnpc" if build.without? "miniupnpc"

    system "./autogen.sh"
    system "./configure", *args

    system "make"
    system "make", "install"
    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end
end
