use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() {
    println!("ros_tokio_demo: hello from tokio");
    sleep(Duration::from_millis(10)).await;
    println!("ros_tokio_demo: bye");
}
