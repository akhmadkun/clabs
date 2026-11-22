# IS-IS • Fabric cRPD dan Lab 01
Topologi permanen: enam cRPD pada br-univ melalui eth1, dua multitool dengan uplink tagged. H1 memakai VLAN 101, 192.168.101.10/24, gateway 192.168.101.1 di R1. H2 memakai VLAN 102, 192.168.102.10/24, gateway 192.168.102.1 di R2. Gambar docs/topologi.png memuat peta logik seri. Subnet transit mengikuti 10.10.xy.0/24; loopback Rx adalah x.x.x.x/32.

## Deploy sekali
Jalankan di direktori yang berisi YAML pada host Linux dengan Docker, containerlab dan kedua image lokal. Nama r1–r6 dan h1–h2 serta port br-univ harus tersedia. Jika lab lama masih menggunakan nama itu, simpan konfigurasinya sebelum menghentikannya. Versi lama yang membuat v12 lewat exec memerlukan migrasi satu kali ke fabric ini. Pada deployment yang sudah memiliki mount dan endpoint identik, cukup salin file skenario ke direktori bind tiap router.

```bash
ip link show br-univ >/dev/null 2>&1 || sudo ip link add br-univ type bridge
sudo ip link set br-univ up
sudo containerlab deploy -t juniper-isis.clab.yml
sudo containerlab inspect -t juniper-isis.clab.yml
docker exec -it r1 cli
```

Jika br-univ memakai vlan_filtering=1, pastikan tagged VLAN diizinkan pada port terkait. Untuk Lab 01, r1_eth1 membutuhkan 12/101, r2_eth1 membutuhkan 12/102, h1_eth1 membutuhkan 101 dan h2_eth1 membutuhkan 102. Periksa dengan bridge vlan show. Pada bridge lab yang meneruskan semua tag, link logik baru cukup ditentukan di file Junos.

## Pilih skenario melalui Junos
Saat boot setiap router memuat configs_crpd/rX/base.conf. Bind direktori per router membuat file baru langsung terlihat sebagai /labconfigs/nama-file. File bernama sama di R1 dan R2 berisi alamat dan konfigurasi milik router masing-masing.

Pada R1–R6, termasuk node yang idle, jalankan:

```text
configure
load override /labconfigs/isis.basic.conf
show | compare
commit check
commit and-quit
```

Mulai Tasks.docx, lalu gunakan Solution-Guide.docx untuk pemeriksaan. R1 dan R2 aktif pada eth1.12; baseline sudah memuat VLAN dan IPv4, sedangkan NET dan protokol IS-IS menjadi tugas. Untuk memuat jawaban lengkap, ulangi prosedur memakai isis.basic.solved.conf. Untuk kembali ke baseline seri gunakan base.conf.

Load override mengganti seluruh candidate configuration. Tinjau show | compare sebelum commit, terutama bila deployment milik sendiri punya user, service management, atau konfigurasi lokal tambahan. Paket ditujukan untuk router lab dengan akses docker exec. File skenario berikutnya ditempatkan di enam direktori yang sama; memuatnya pada semua router membersihkan state konfigurasi skenario sebelumnya, termasuk pada node idle.

Untuk skenario yang memerlukan platform vJunos, template vJunos terpisah milik lu menyediakan /labconfigs melalui HTTP wrapper port 81. Workflow di guest adalah load override http://10.0.0.2:81/nama-skenario.cfg routing-instance mgmt_junos, lalu show | compare, commit check dan commit. File override untuk platform itu perlu memuat baseline management/akses HTTP milik guest agar skenario berikutnya tetap dapat dimuat.
