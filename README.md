# US_Stock

# Stocks （Mocking project）

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project
這個project是模仿蘋果原生的看盤程式Stocks，是我用來練習Combine跟加強寫出乾淨程式碼的能力

圖表的部分我是使用 iOS Charts，所有的資料都是由ALPHA VANTAGE API提供，網路層使用原生的URLSession，搭配Combine對各個事件分別處理，
使用者可以儲存自己想看的標的，我建立了core data service 這個類別，專門處理儲存標的資料。

### Built With

* Combine
* Core Data
* iOS Charts
* MBProgressHUD


<!-- GETTING STARTED -->
## Getting Started

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/hanlinchentw/US_Stocks.git
   ```
2. Open Terminal 
```sh
   pod init
   pod install
   ```
<!-- Usage -->
## Usage 
### Stock Detail
![image](https://github.com/hanlinchentw/US_Stocks/blob/main/Stock_Detail.png)
![image](https://github.com/hanlinchentw/US_Stock/blob/main/Stock_Chart_demo.gif)

### List
![image](https://github.com/hanlinchentw/US_Stocks/blob/main/Stock_List.png)
![image](https://github.com/hanlinchentw/US_Stocks/blob/main/Stock_add.png)
![image](https://github.com/hanlinchentw/US_Stocks/blob/main/Stock_delete.png)

### Demo
![image](https://github.com/hanlinchentw/US_Stocks/blob/main/Stock%20Gif.gif)

<!-- CONTACT -->
## Contact

### iOS Developer
陳翰霖 Chen, Han-Lin - [Linkedin](https://www.linkedin.com/in/han-lin-chen-07b635200/) - s3876531@gmail.com

<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [iOS Charts](https://github.com/danielgindi/Charts)
* [MBProgressHUD](https://github.com/jdg/MBProgressHUD)
