#!/bin/bash

# 2D Array
a=('a1=(n1 n2 n3)' 'a2=(m1 m2 m3)')

for i in "${a[@]}"; do
    eval "${i}"
done

x=0;y=2
echo "${a1[${x}]}${a2[${y}]}"




# 3D Array
a=('a1=(n1 n2 n3)' 'a2=(m1 m2 m3)' 'a3=(o1 o2 o3)')

for i in "${a[@]}"; do
  eval "${i}"
done

x=0;y=2;z=1
echo "${a1[${x}]}${a2[${y}]}${a3[${z}]}"
