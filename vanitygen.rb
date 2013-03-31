require 'formula'

class Vanitygen < Formula
  gh = 'https://github.com/samr7/vanitygen'
  repo = gh+'.git'
  revision = 'cd1a7282431dcf7e522777976aa18728ee5bb7be'
  homepage gh
  head repo
  #head as of 201303262300
  url repo, :revision => revision
  version revision.slice(0,8)

  devel do
    url repo, :branch => 'master'
    version 'master'
  end

  depends_on 'pcre'
  depends_on 'openssl'

  def patches
    DATA
  end

  def install
    system "make", "all"
    %w[keyconv oclvanitygen oclvanityminer vanitygen].each do |binary|
      system "strip #{binary}"
      bin.install binary
    end
  end
end
__END__
diff --git a/vanitygen.c b/vanitygen.c
index 9d88121..86b9fe5 100644
--- a/vanitygen.c
+++ b/vanitygen.c
@@ -244,20 +244,7 @@
 int
 count_processors(void)
 {
-	FILE *fp;
-	char buf[512];
-	int count = 0;
-
-	fp = fopen("/proc/cpuinfo", "r");
-	if (!fp)
-		return -1;
-
-	while (fgets(buf, sizeof(buf), fp)) {
-		if (!strncmp(buf, "processor\t", 10))
-			count += 1;
-	}
-	fclose(fp);
-	return count;
+    return sysconf( _SC_NPROCESSORS_ONLN );
 }
 #endif
