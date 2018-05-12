use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;
use std::str;

fn to_hex(input: u32) -> String { //this is disgusting but it works
  let res = format!("{:x}", input);
  if(res.len() == 0) {
    return format!("0000");
  }
  else if(res.len() == 1) {
    return format!("000{}", res);
  }
  else if(res.len() == 2) {
    return format!("00{}", res);
  }
  else if(res.len() == 3) {
    return format!("0{}", res);
  }
  res
}

fn char_at(s: &mut String, loc: u64) -> char {
  if loc as usize >= s.len() {
    return '/';
  }
  return s.chars().nth(loc as usize).unwrap();
}

fn main() {
  /* START: Read contents */
  let file = File::open("output.s").expect("output.s not found");
  let mut out = File::create("temp.mif").unwrap();

  let mut buf_reader = BufReader::new(file);
  let mut contents = String::new();
  buf_reader.read_to_string(&mut contents);
  let mut contents_iterator = contents.split("\n");
  /* END: Read contents */

  /* START: initial read of ISA */
  let mut address: u32 = 1;
  let mut main_address: u32 = 0;
  let mut data = false;
  let mut func = false;
  let mut main = false;
  let mut processing_func = false;
  let mut vars = HashMap::new();
  let mut funcs = HashMap::new();

  for content in contents_iterator {
    let mut ins = content.to_string();
    if(ins == ".DATA") { // the DATA block
      data = true;
      func = false;
      main = false;
    }
    else if(ins == ".FUNCTIONS") {
      address -=1;
      func = true;
      data = false;
      main = false;
    }
    else if(ins == ".MAIN") {
      main = true;
      data = false;
      func = false;
    }
    else if(data) {
      let len = content.len();
      ins.truncate(len-2);       
      out.write_fmt(format_args!("0000\n"));
      vars.insert(format!("${}", ins), address);
      address += 1;
    }
    else if(func) {
      let len = content.len();
      if(ins.chars().last().unwrap() == ':') {
        if(processing_func) {
          address -= 1;
        }
        processing_func = true;
        ins.truncate(len-1);
        address += 1;
        funcs.insert(format!("${}", ins), address);
      }
      else {
        out.write_fmt(format_args!("{}\n", ins)); //write the thing to be formatted later
        address += 1;
      }
    }
    else if(main) {
      if(!ins.is_empty()) { //the program is over
        let len = content.len();
        if(ins.chars().last().unwrap() == ':') { //it's a block again
          address += 1;
          if(main_address == 0) {
            main_address = address; //need to place inside incase block is first line
          }
          ins.truncate(len-1);
          funcs.insert(format!("${}", ins), address);
        }
        else {
          out.write_fmt(format_args!("{}\n", ins));
          if(main_address == 0) {
            main_address = address;
          }
          address += 1;
        }
      }
    }
  }
  /* END: initial read of ISA */

  // // this block is for checking addresses and such
  // for (key, val) in vars.iter() {
  //   println!("There is a var {} with address {}", key, to_hex(*val));
  // }
  // for (key, val) in funcs.iter() {
  //   println!("there is a func {} with address {}", key, to_hex(*val));
  // }
  // println!("the main address is at {}", main_address);

  /* START: resolve ISA tags */
  let temp = File::open("temp.mif").expect("temp.mif should've bene made");
  let mut out_file = File::create("output.mif").unwrap();
  let mut buf_reader2 = BufReader::new(temp);
  let mut contents2 = String::new();
  buf_reader2.read_to_string(&mut contents2);
  let mut contents_iterator2 = contents2.split("\n");
  out_file.write_fmt(format_args!("{}\n", to_hex(main_address)));

  for content in contents_iterator2 {
    let mut res = content.to_string();
    if(!res.is_empty()) {
      if(res.chars().next().unwrap().is_digit(10)) { //if its an address
        out_file.write_fmt(format_args!("{}\n", res));
      }
      else { //it's an instruction or perhaps a tag
        if(res.chars().next().unwrap() == '$') { // if it's a tag
          let out = funcs.get(&res).expect("the res should exist");
          out_file.write_fmt(format_args!("{}\n", to_hex(*out)));
        }
        else { //it's an action
          /* START: get params */
          let mut op = String::new();
          let mut p1 = String::new();
          let mut p2 = String::new();
          let mut p3 = String::new();
          let mut found_op = false;
          let mut found_p1 = false;
          let mut found_p2 = false;
          let mut instruction = String::new();
          let chars = res.chars();
          for c in chars {
            if(c == ' ') {
              found_op = true;
            }
            else if(!found_op) {
              op.push(c);
            }
            else {
              if(!found_p1) {
                if(c == ',') {
                  found_p1 = true;
                }
                else {
                  p1.push(c);
                }
              }
              else if(!found_p2){
                if(c == ',') {
                  found_p2 = true;
                }
                else {
                  p2.push(c);
                }
              }
              else {
                p3.push(c);
              }
            }
          }
          /* END: get params */
          if(op == "add") {
            instruction.push('0');
            instruction.push(char_at(&mut p2, 1));
            instruction.push(char_at(&mut p3, 1));
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "mul") {
            instruction.push('1');
            instruction.push(char_at(&mut p2, 1));
            instruction.push(char_at(&mut p3, 1));
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "movl") {
            instruction.push('8');
            if(char_at(&mut p2, 0) == '$') { //it's a tag
              if(char_at(&mut p2, 1) == 'F') { //it's a func
                let mut hex = to_hex(*funcs.get(&p2).expect("func should exist"));
                instruction.push(char_at(&mut hex, 2));
                instruction.push(char_at(&mut hex, 3));
              }
              else {
                let mut hex = to_hex(*vars.get(&p2).expect("var should exist"));
                instruction.push(char_at(&mut hex, 2));
                instruction.push(char_at(&mut hex, 3));
              }
            }
            else {
              let mut hex = to_hex(p2.parse::<u32>().unwrap());
              instruction.push(char_at(&mut hex, 2));
              instruction.push(char_at(&mut hex, 3));
            }
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "movh") {
            instruction.push('9');
            if(char_at(&mut p2, 0) == '$') { //it's a tag
              if(char_at(&mut p2, 1) == 'F') { //it's a func
                let mut hex = to_hex(*funcs.get(&p2).expect("func should exist"));
                instruction.push(char_at(&mut hex, 0));
                instruction.push(char_at(&mut hex, 1));
              }
              else {
                let mut hex = to_hex(*vars.get(&p2).expect("var should exist"));
                instruction.push(char_at(&mut hex, 0));
                instruction.push(char_at(&mut hex, 1));
              }
            }
            else {
              let mut hex = to_hex(p2.parse::<u32>().expect("wtf is happening "));
              instruction.push(char_at(&mut hex, 2));
              instruction.push(char_at(&mut hex, 3));
            }
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "movpc") {
            instruction.push('a');
            instruction.push('0');
            instruction.push('0');
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "jz") {
            instruction.push('e');
            instruction.push(char_at(&mut p2, 1));
            instruction.push('0');
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "jmp") {
            instruction.push('e');
            instruction.push('f');
            instruction.push('1');
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "jmpa") {
            instruction.push('e');
            instruction.push('f');
            instruction.push('2');
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "jzn") {
            instruction.push('e');
            instruction.push(char_at(&mut p1, 1));
            instruction.push('f');
            instruction.push('f');
          }
          else if(op == "ld") {
            instruction.push('f');
            instruction.push(char_at(&mut p2, 1));
            instruction.push('0');
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "st") {
            instruction.push('f');
            instruction.push(char_at(&mut p2, 1));
            instruction.push('1');
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "cmp") {
            instruction.push('2');
            instruction.push(char_at(&mut p2, 1));
            instruction.push(char_at(&mut p3, 1));
            instruction.push(char_at(&mut p1, 1));
          }
          else if(op == "in") {
            instruction.push('7');
            instruction.push('0');
            instruction.push('0');
            instruction.push(char_at(&mut p1, 1));
          }
          else {
            println!("wtf happened");
          }
          out_file.write_fmt(format_args!("{}\n", instruction));
        }
      }
    }
  }
  out_file.write_fmt(format_args!("ffff"));
  /* END: resolve ISA tags */
}
