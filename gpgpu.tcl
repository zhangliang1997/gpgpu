set device xc7k70t
set package fbg676
set speed -1 
set part  $device$package$speed
set projectName gpgpu
set projectDir  ./gpgpu_vivado
set srcDir      ./hw

create_project $projectName $projectDir -part $part  -force

add_files [glob $srcDir/core/*.sv]
add_files [glob $srcDir/core/*.svh]

#update_compile_order -fileset sources_1






start_gui

