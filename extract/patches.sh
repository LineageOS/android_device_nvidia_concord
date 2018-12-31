# Copyright (C) 2023 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Several t234 bct files are shipped with preprod values in l4t, then the flash scripts modify them for prod silicon
# Just fix them up during extract
function patch_preprod() {
  sed -i 's/preprod_dev_sign = <1>/preprod_dev_sign = <0>/' ${LINEAGE_ROOT}/${OUTDIR}/concord/r35/BCT/tegra234-br-bct-diag-boot.dts
  sed -i 's/preprod_dev_sign = <1>/preprod_dev_sign = <0>/' ${LINEAGE_ROOT}/${OUTDIR}/concord/r35/BCT/tegra234-br-bct-p3701-0000.dts
  sed -i 's/preprod_dev_sign = <1>/preprod_dev_sign = <0>/' ${LINEAGE_ROOT}/${OUTDIR}/concord/r35/BCT/tegra234-br-bct_b-p3701-0000.dts
  sed -i 's/preprod_dev_sign = <1>/preprod_dev_sign = <0>/' ${LINEAGE_ROOT}/${OUTDIR}/concord/r35/BCT/tegra234-br-bct-p3767-0000-l4t.dts
  sed -i 's/preprod_dev_sign = <1>/preprod_dev_sign = <0>/' ${LINEAGE_ROOT}/${OUTDIR}/concord/r35/BCT/tegra234-br-bct_b-p3767-0000-l4t.dts
}

patch_preprod;
