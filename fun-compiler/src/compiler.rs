use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::collections::HashMap;

//Ok so the plan is right now to not have parentheses so I dont need to use a stack
//Now I can just have a temp variable for each e level that I move the value into.
//Make an instruction to store the PC in a special PC register

const ELSE: u8 = 0;
const END: u8 = 1;
const EQ: u8 = 2;
const EQEQ: u8 = 3;
const ID: u8 = 4;
const IF: u8 = 5;
const INT: u8 = 6;
const LBRACE: u8 = 7;
const LEFT: u8 = 8;
const MUL: u8 = 9;
const NONE: u8 = 10;
const PLUS: u8 = 11;
const PRINT: u8 = 12;
const RBRACE: u8 = 13;
const RIGHT: u8 = 14;
const SEMI: u8 = 15;
const WHILE: u8 = 16;
const FUN: u8 = 17;

struct Token {
  kind: u8,
  start_in: usize,
  end_in: usize
}

struct Interpreter_State {
  curr_token: Token,
  table: HashMap<Vec<u8>, u64>,
  input: Vec<u8>,
  tag_count: u64
}


fn peek(state: &mut Interpreter_State) -> u8 {
  if state.curr_token.kind == NONE && state.curr_token.start_in == 
    state.curr_token.end_in {
    consume(state);
  }
  let ans: u8;
  if isend(state) {
    return END;
  }
  if isDigit(state.input[state.curr_token.start_in]) {
    return INT;
  }
  match state.input[state.curr_token.start_in] {
    0 => {ans = END;}
    61 => {if state.input[state.curr_token.start_in + 1] == 61 {
      ans = EQEQ;
    } else {
      ans = EQ;
    }}
    b'{' => {ans = LBRACE;}
    b'(' => {ans = LEFT;}
    b')' => {ans = RIGHT;}
    b'*' => {ans = MUL;}
    b'+' => {ans = PLUS;}
    b'}' => {ans = RBRACE;}
    b';' => {ans = SEMI;}
    _ => {
      let slice = &state.input[state.curr_token.start_in..state.curr_token.end_in];
      if (String::from("else").into_bytes()) == slice {
        ans = ELSE;
      } else if (String::from("fun").into_bytes()) == slice {
        //println!("fun!!! start: {}", state.curr_token.start_in);
        ans = FUN;
      } else if (String::from("if").into_bytes()) == slice {
        ans = IF;
      } else if (String::from("while").into_bytes()) == slice {
        ans = WHILE;
      } else if (String::from("print").into_bytes()) == slice {
        ans = PRINT;
      } else {
        ans = ID;
      }
    }
  }
  return ans;
}

fn consume(state: &mut Interpreter_State) {
  state.curr_token.start_in = state.curr_token.end_in;
  //println!("consuming! startin = {}", state.curr_token.start_in);
  while !isend(state) && is_space(state.input[state.curr_token.start_in]) {
    state.curr_token.start_in = state.curr_token.start_in + 1;
  }
  state.curr_token.end_in = state.curr_token.start_in + 1;
  
  if isend(state) {
    return;
  }

  //println!("first_end {:?}", state.curr_token.end_in);
  if isDigit(state.input[state.curr_token.start_in]) {
    while !issoftend(state) && state.input[state.curr_token.end_in] == b'_' ||
        isDigit(state.input[state.curr_token.end_in]) {
      state.curr_token.end_in = state.curr_token.end_in + 1;
    }
  } else if isPunct(state.input[state.curr_token.start_in]) {
    if state.input[state.curr_token.start_in] == b'=' && 
        state.input[state.curr_token.start_in + 1] == b'=' {
      state.curr_token.end_in = state.curr_token.end_in + 1;
    }
  } else if isLower(state.input[state.curr_token.start_in]) {
    while !issoftend(state) && isAlNum(state.input[state.curr_token.end_in]) {
      state.curr_token.end_in = state.curr_token.end_in + 1;
    }
  }
  //println!("second_end {:?}", state.curr_token.end_in);

  state.curr_token.kind = peek(state);
  //println!("fin_type {:?}", state.curr_token.kind);
}

fn issoftend(state: &mut Interpreter_State) -> bool {
  return state.curr_token.end_in >= state.input.len();
}

fn isend(state: &mut Interpreter_State) -> bool {
  return state.curr_token.start_in >= state.input.len() || 
    state.curr_token.end_in > state.input.len();
}


fn isLower(check: u8) -> bool {
  return check >= 97 && check <= 122;
}

fn isAlNum(check: u8) -> bool {
  return isDigit(check) || (check >= 65 && check <= 90) ||
    (check >= 97 && check <= 122);
}

fn isPunct(check: u8) -> bool {
  return !isAlNum(check);
}

fn isDigit(check: u8) -> bool {
  return check >= 48 && check <= 57;
}

fn get_id(state: &Interpreter_State) -> &[u8] {
  return &state.input[state.curr_token.start_in..state.curr_token.end_in];
}

fn get_int(state: &Interpreter_State) -> u64 {
  let mut ans: u64 = 0;
  for i in &state.input[state.curr_token.start_in..state.curr_token.end_in] {
    if isDigit(*i) {
      ans = ans * 10 + ((i - b'0') as u64);
    }
  }
  //println!("get_int result: {}", ans);
  return ans;
}

fn is_space(check: u8) -> bool {
  return check == 0x20 || (check >= 0x09 &&
      check <= 0x0d);
}

fn e1(state: &mut Interpreter_State, outfile: &mut File, doit: bool) {
  //if peek(state) == LEFT {
  //  consume(state);
  //  let v = expression(state);
  //  if peek(state) != RIGHT {
  //    println!("1ERROR");
  //  }
  //  consume(state);
  //  return v;
  //} else 
  if peek(state) == INT {
    let v = get_int(state);
    consume(state);
    if doit {
      outfile.write_fmt(format_args!("movl r1,{}\n",v % 256));
      outfile.write_fmt(format_args!("movh r1,{}\n",v / 256));
    }
  } else if peek(state) == ID {
    let id = get_id(state).to_vec();
    consume(state);
    let res = state.table.get(&id);
    if doit {
      if res.is_some() {
        let v = *res.unwrap();
        outfile.write_fmt(format_args!("movl r1,{}\n",v % 256));
        outfile.write_fmt(format_args!("movh r1,{}\n",v / 256));
        //ld r1,r1
        outfile.write_fmt(format_args!("ld r1,r1\n"));
      } else {
        //movl r1, 0
        outfile.write_fmt(format_args!("movl r1,{}\n",0));
        outfile.write_fmt(format_args!("movh r1,{}\n",0));
      }
    }
  } else if peek(state) == FUN {
    let v = state.curr_token.start_in as u64;
    consume(state);
    statement(state, false, outfile);
    if doit {
      outfile.write_fmt(format_args!("movh r1,$F{}\n",v));
      outfile.write_fmt(format_args!("movl r1,$F{}\n",v));
    }
  } else {
    println!("2ERROR | start: {}, end: {}, type: {}",
        state.curr_token.start_in, state.curr_token.end_in,
        state.curr_token.kind);
  }
}

fn e2(state: &mut Interpreter_State, outfile: &mut File, doit: bool) {
  e1(state, outfile, doit);
  if doit {
    outfile.write_fmt(format_args!("add r2,r0,r1\n"));
  }
  while peek(state) == MUL {
    consume(state);
    //value = value * e1(state);
    e1(state, outfile, doit);
    if doit {
      outfile.write_fmt(format_args!("mul r2,r1,r2\n"));
    }
  }
}

fn e3(state: &mut Interpreter_State, outfile: &mut File, doit: bool) -> u64 {
  e2(state, outfile, doit);
  if doit {
    outfile.write_fmt(format_args!("add r3,r0,r2\n"));
  }
  while peek(state) == PLUS {
    consume(state);
    //value = value + e2(state);
    e2(state, outfile, doit);
    if doit {
      outfile.write_fmt(format_args!("add r3,r2,r3\n"));
    }
  }
}

fn e4(state: &mut Interpreter_State, outfile: &mut File, doit: bool) -> u64 {
  e3(state, outfile, doit);
  if doit {
    outfile.write_fmt(format_args!("add r4,r0,r3\n"));
  }
  while peek(state) == EQEQ {
    consume(state);
    if doit {
      outfile.write_fmt(format_args!("cmp r4,r4,r3\n"));
    }
  }
}

fn expression (state: &mut Interpreter_State, outfile: &mut File, doit: bool) {
  e4(state, outfile, doit);
}

fn statement(state: &mut Interpreter_State, doit:bool, outfile: &mut File) -> bool {
  match peek(state) {
    ID => {
      let id = get_id(state).to_vec();
      consume(state);
      let temp_k = peek(state);
      if temp_k == END {
        return false;
      } else if temp_k == EQ {
        consume(state);
        expression(state, outfile, doit);
        if doit {
          outfile.write_fmt(format_args!("movl r5,${}\n",id));
          outfile.write_fmt(format_args!("movh r5,${}\n",id));
          outfile.write_fmt(format_args!("st r4,r5\n"));
        }
      } else if temp_k == LEFT {
        //println!("function call!!!");
        consume(state);
        if peek(state) != RIGHT {
          println!("3ERROR");
        }
        consume(state);
        if doit {
          //let prevstart = state.curr_token.start_in;
          //let prevend = state.curr_token.end_in;
          //state.curr_token.start_in = *state.table.get(&id).unwrap() as usize;
          //state.curr_token.end_in = state.curr_token.start_in + 3;
          //consume(state);
          //statement(state, doit);
          //state.curr_token.start_in = prevstart;
          //state.curr_token.end_in = prevend;
          outfile.write_fmt(format_args!("movl r5,${}\n",id));
          outfile.write_fmt(format_args!("movh r5,${}\n",id));
          outfile.write_fmt(format_args!("ld r5,r5\n"));
          outfile.write_fmt(format_args!("movpc r7\n"));
          outfile.write_fmt(format_args!("jmp r5\n"));
        }
      } else {
        println!("4ERROR | start: {}, end: {}, type: {}, doit: {}",
            state.curr_token.start_in, state.curr_token.end_in,
            state.curr_token.kind, doit);
      }

      if peek(state) == SEMI {
        consume(state);
      }
      return true;
    }
    LBRACE => {
      consume(state);
      seq(state, doit, outfile);
      if peek(state) != RBRACE {
        println!("5ERROR");
      }
      //println!("{}", state.curr_token.kind);
      consume(state);
      //println!("{}", state.curr_token.kind);
      return true;
    }
    //TODO: NESTING FOR IFS
    IF => {
      consume(state);
      expression(state, outfile, doit);
      let temp_tag_count = state.tag_count;
      if doit {
        state.tag_count = state.tag_count + 1;
        outfile.write_fmt(format_args!("jzn r4\n"));
        outfile.write_fmt(format_args!("$ELSE{}\n", temp_tag_count));
      }
      statement(state, doit, outfile);
      if doit {
        outfile.write_fmt(format_args!("jzn r0\n"));
        outfile.write_fmt(format_args!("$DONE{}\n", temp_tag_count));
        outfile.write_fmt(format_args!("ELSE{}:\n", temp_tag_count));
      }
      let tempKind = peek(state);
      if tempKind == SEMI {
        consume(state);
      }
      if tempKind == ELSE {
        consume(state);
        statement(state, doit, outfile);
      }
      if doit {
        outfile.write_fmt(format_args!("DONE{}:\n", temp_tag_count));
      }
      return true;
    }
    WHILE => {
      consume(state);
      //let start = state.curr_token.start_in;
      //let end = state.curr_token.end_in;
      let temp_tag_count = state.tag_count;
      if doit {
        state.tag_count = state.tag_count + 1;
        outfile.write_fmt(format_args!("WHILE{}:\n", temp_tag_count));
      }
      expression(state, outfile, doit);
      if doit {
        outfile.write_fmt(format_args!("jzn r4\n"));
        outfile.write_fmt(format_args!("$DONE{}\n", temp_tag_count));
      }
      statement(state, doit, outfile);
      if doit {
        outfile.write_fmt(format_args!("jzn r0\n"));
        outfile.write_fmt(format_args!("$WHILE{}\n", temp_tag_count));
        outfile.write_fmt(format_args!("DONE{}:\n", temp_tag_count));
      }
      //while expression(state) != 0 && doit {
      //  statement(state, true);
      //  state.curr_token.start_in = start;
      //  state.curr_token.end_in = end;
      //  peek(state);
      //}
      statement(state, false);
      return true;
    }
    PRINT => {
      //println!("Should be printing!");
      consume(state);
      if peek(state) == SEMI {
        return true;
      }
      expression(state, outfile, doit);
      if doit {
        outfile.write_fmt(format_args!("add r0,r4,r0\n"));
      }
      return true;
    }
    SEMI => {
      consume(state);
      return true;
    }
    END => {
      return false;
    }
    _ =>{
      //println!("6ERROR start: {}, end: {}, type: {}", state.curr_token.start_in,
      //    state.curr_token.end_in, state.curr_token.kind);
      return false;
    }
  }
}

fn seq(state: &mut Interpreter_State, doit: bool, outfile: &mut File) {
  while statement(state, doit){}
}

fn program(state: &mut Interpreter_State, outfile: &mut File) {
  seq(state, true);
  if peek(state) != END {
    println!("failed!");
  }
}

fn variables(state: &mut Interpreter_State, outfile: &mut File) {
  state.curr_token = Token{kind: NONE, start_in: 0, end_in: 0};
  outfile.write_fmt(format_args!(".DATA\n"));
  while peek(state) != END {
    if peek(state) == ID &&
      !state.table.contains_key(&get_id(state).to_vec()) {
      state.table.insert(get_id(state).to_vec(), 0);
      outfile.write_fmt(format_args!("{}:0\n", &get_id(state).to_vec()));
    }
  }
  state.curr_token = Token{kind: NONE, start_in: 0, end_in: 0};
}

fn functions(state: &mut Interpreter_State, outfile: &mut File) {
  state.curr_token = Token{kind: NONE, start_in: 0, end_in: 0};
  outfile.write_fmt(formart_args!(".FUNCTIONS\n"));
  while peek(state) != END {
    if(peek(state) == FUN) {
      let prev_start = state.curr_token.start_in;
      let prev_end = state.curr_token.end_in;
      outfile.write_fmt(format_args!("F{}:\n", prev_start));
      consume(state);
      statement(state, outfile, true);
      state.curr_token.start_in = prev_start;
      state.curr_token.end_in = prev_end;
      outfile.write_fmt(format_args!("jmpa r7,4\n"));
    }
    consume(state);
  }
  state.curr_token = Token{kind: NONE, start_in: 0, end_in: 0};
}

fn main() {
  let args: Vec<String> = env::args().collect();
  let filename = &args[1];
  
  let mut f = File::open(filename).expect("File not found.");
  let mut outfile = File::create("output.mif")?;

  let mut all_content = String::new();
  f.read_to_string(&mut all_content)
    .expect("something went wrong with reading the file");

  let mut state = Interpreter_State {
    curr_token: Token{kind: NONE, start_in: 0, end_in: 0},
    table: HashMap::new(),
    input: all_content.into_bytes(),
    tag_count: 0
  };

  variables(&mut state, &mut outfile);
  functions(&mut state, &mut outfile);
  outfile.write_fmt(format_args!(".MAIN\n"));
  
  //outfile.write_fmt(format_args!("{:04x}\n", varCount));
  //let tempCount = 2;
  //while tempCount < varCount {
  //  outfile.write_fmt(format_args!("{:04x}\n", 0));
  //  let tempCount = tempCount + 2;
  //}

  //let v1 = vec!(1, 2, 3, 4, 5);
  //let v2 = vec!(1, 2, 3);
  //let mut hoo = HashMap::new();
  //hoo.insert(&v1[0..3], 12);
  //println!("hello {:?}", hoo.get(&v2[0..3]));
  //hoo.insert(&v2[0..3], 69);
  //println!("hello {:?}", hoo.get(&v1[0..3]));

  //println!("Text: \n{:?}\n{}", state.input, state.input.len());

  program(&mut state, &mut outfile);
}
