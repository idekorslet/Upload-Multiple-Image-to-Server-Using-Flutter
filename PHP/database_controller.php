<?php
    require_once 'connection.php';


    class DatabaseController {
        public $total_data_inserted = 0;

        public function insertData($connection, $data, $sql) {
            try {
                // contoh - example:
                // $sql = "INSERT INTO products (seller_id, title, description, price, stock) VALUES (?, ?, ?, ?, ?)";
    
                // $data = array(
                //     [22, "baju", "baju kerja", 100000, 10],
                //     [22, "baju", "sepatu sekolah", 100000, 10],
                //     [21, "baju", "tas sekolah", 100000, 10],         
                // );

                $statement = $connection->prepare($sql);
                $connection->beginTransaction();
                
                foreach ($data as $row) {
                    $statement->execute($row);
                    // echo $statement->rowCount() . "<br>";
                    $this->total_data_inserted++;
                }

                $connection->commit();
            } catch (Exception $e) {
                $connection->rollback();
                echo "Failed to insert data: $e";
                $this->total_data_inserted = 0;
                return;
            }
            finally {
                // echo "Total data inserted: " . $this->total_data_inserted;
                $connection = null;
            }
        }

    }