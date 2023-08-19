<?php
    require_once 'utils.php';
    require_once 'connection.php';
    require_once 'database_controller.php';


    $full_path_image_folder = __DIR__ . "/images";

    if (isset($_FILES['userfile'])) {

        $db_ctrl = new DatabaseController();

        $userfile = reArrayFiles($_FILES['userfile']);

        // lakukan looping sebanyak jumlah image yang ada - do loop process as much image length
        for ($image_index = 0; $image_index < count($userfile); $image_index++) {

            // ambil data yang diperlukan seperti nama file image dan lokasi temporary image
            // take the neccessary data, like image name and image temporary file location
            $image_name = $userfile[$image_index]['name'];
            $image_file = $userfile[$image_index]['tmp_name'];

            // simpan lokasi image ke database
            // save image path into database
            $sql = "INSERT INTO images (image_path, image_index) VALUES (?, ?)";

            $data = array(
                [$image_name, $image_index],
            );

            $db_ctrl->insertData($connection, $data, $sql);

            // copy image ke file sistem setelah sukses insert image ke database 
            // copy image into file system after image inserted into database

            // cek apakah sudah ada folder imagenya atau belum - check the image folder, exists or not
            if (!is_dir($full_path_image_folder)) {
                // echo "images_folder not exists, creating image folder<br>";
                mkdir($full_path_image_folder, 0755, true);
            }

            // simpan image ke file sistem - save image into file system
            $full_path_image = $full_path_image_folder . "/" . $image_name;

            if (move_uploaded_file($image_file, $full_path_image)) {

                // if (file_exists($full_path_image)) {

                //     echo "Image $image_name - created successfully<br>";     

                // }

            }

        }

        $result = [
            "info" => "OK",
            "error_msg" => "",
            "total_image_uploaded" => $db_ctrl->total_data_inserted
        ];

        header('Content-Type: application/json');
        echo json_encode($result);
    }

