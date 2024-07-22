class Cbmc < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.1.0",
      revision: "737d5826d29df048493b88caad9b70aa217db687"
  license "BSD-4-Clause"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "66acf01f024060d938502b52547b76d85ec17cec4a9943cddba8dc6a715064ce"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "f802386943fe3366bd7dc59f4c569d43d4c1340bd597dfa232528cc1fe9b327e"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "13445c9f823acda295337c06f26abd95d119de1e70c4dbe025c576a0d7e96ec0"
    sha256 cellar: :any_skip_relocation, sonoma:         "828fc6aa82d12e11209a359e266a65cdcd959dfee0cb02cb54ca6869a06b8d4f"
    sha256 cellar: :any_skip_relocation, ventura:        "ed9b7b4e9997cc57f950f2494f2a06653b04da4b123b1f1697c159b72205983b"
    sha256 cellar: :any_skip_relocation, monterey:       "3d4ca4617591f98c492428364e8fda7d0f9163af727ab4ec6b24e32675212dc6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "ae0c0bcad5a001a192d688484cec2051265ed29151f1198204265fee3c0d4dbe"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk@21" => :build
  depends_on "rust" => :build

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  fails_with gcc: "5"

  def install
    # Fixes: *** No rule to make target 'bin/goto-gcc',
    # needed by '/tmp/cbmc-20240525-215493-ru4krx/regression/goto-gcc/archives/libour_archive.a'.  Stop.
    ENV.deparallelize
    ENV["JAVA_HOME"] = Formula["openjdk@21"].opt_prefix

    system "cmake", "-S", ".", "-B", "build", "-Dsat_impl=minisat2;cadical", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # lib contains only `jar` files
    libexec.install lib
  end

  test do
    # Find a pointer out of bounds error
    (testpath/"main.c").write <<~EOS
      #include <stdlib.h>
      int main() {
        char *ptr = malloc(10);
        char c = ptr[10];
      }
    EOS
    assert_match "VERIFICATION FAILED",
                 shell_output("#{bin}/cbmc --pointer-check main.c", 10)
  end
end
