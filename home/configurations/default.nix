{self, ...} @ inputs: {
  "nmelzer@mimas" = self.lib.mkHome "nmelzer" "mimas" "x86_64-linux" inputs.unstable;
  "nmelzer@enceladeus" = self.lib.mkHome "nmelzer" "enceladeus" "x86_64-linux" inputs.unstable;
}
