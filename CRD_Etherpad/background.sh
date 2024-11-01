sudo rm -rf /usr/local/go

sudo apt-get remove -y golang-go

sudo apt-get autoremove -y


GO_VERSION="1.23.1"

wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz

sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz


echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc

source ~/.bashrc

sudo mkdir -p /mnt/data/etherpad /mnt/data/mysql


cat <<EOF > pv-pvc.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: etherpad-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data/etherpad"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: etherpad-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data/mysql"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

kubectl apply -f pv-pvc.yml
