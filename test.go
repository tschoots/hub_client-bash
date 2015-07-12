package main

import "encoding/json"
import "fmt"


type Response2 struct {
   Page int         `json:"page"`
   Name string      `json:"name"`
   Fruits []string  `json:"fruits"`
}



func main() {
   res2D := &Response2{
        Page: 1,
        Fruits: []string{"apple", "peach", "pear"}}
   res2B,_ := json.Marshal(res2D)
   fmt.Println(string(res2B))

   prr := new(Response2)
   prr.Page = 3
   prr.Name = "hallo hallo"
   trr,_:=json.Marshal(prr)
   fmt.Println(string(trr))
}
