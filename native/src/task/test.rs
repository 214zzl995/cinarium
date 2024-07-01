#[cfg(test)]
mod test {
    use cinarium_crawler::Template;
    use dotenvy::dotenv;

    use crate::model::VideoDataInterim;

    #[test]
    pub fn test() {
        dotenv().ok();
        let mut temp = Template::<VideoDataInterim>::from_json(include_str!(
            "../../cinarium-crawler/default/db.json"
        ))
        .unwrap();

        temp.add_parameters("crawl_name", std::env::var("CRAWL_NAME").unwrap().as_str());
        temp.add_parameters("base_url", std::env::var("BASE_URL").unwrap().as_str());
        let ss = temp.crawler_block(&std::env::var("REQUEST_URL").unwrap());
        println!("{:?}", ss);
    }
}
