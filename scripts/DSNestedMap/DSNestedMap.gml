
#macro DS_NESTED_MAP_STR_MARKER "*"
#macro DS_NESTED_MAP_NUM_MARKER "."
#macro DS_NESTED_MAP_KEY_MARKER ";"

/**
  * @desc TODO
  *
  */
function DSNestedMap() constructor {
  
  data  = {};
  vocab = ds_map_create();
  
  __vocab_size = 0; // for vocab ids
    
  /**
   * @desc Stores a value at a specified path. Requires at least least one key and one value as arguments
   * 
   * @param {String|Any} keys - Sequence of keys followed by the value to store
   */
  static set = function(/*...*/) {
    if (argument_count < 2) exit;
    
    var _i = 0, _key = "", _val;
    repeat (argument_count - 1) {
      _val = argument[_i];
      
      if (is_string(_val)) {
        _key += DS_NESTED_MAP_STR_MARKER;
        _key += _val;
      } else if (is_numeric(_val)) {
        _key += DS_NESTED_MAP_NUM_MARKER;
        _key += string(_val);
      } else {
        if (!ds_map_exists(vocab, _val)) {
          vocab[? _val] = string(__vocab_size) + DS_NESTED_MAP_KEY_MARKER;
          ++__vocab_size;
        }
        
        _key += vocab[? _val];
      }
      ++_i;
    }
    
    data[$ _key] = argument[_i];
  }
    
  /**
   * @desc Retrieves a value from the specified path
   * 
   * @param {String} keys - Sequence of keys
   * @returns {Any} Value at the specified path or undefined if path invalid
   */
  static get = function(/*...*/) {
    if (argument_count < 1) exit;
    
    var _i = 0, _key = "", _val;
    repeat (argument_count) {
      _val = argument[_i];
      
      if (is_string(_val)) {
        _key += DS_NESTED_MAP_STR_MARKER;
        _key += _val;
      } else if (is_numeric(_val)) {
        _key += DS_NESTED_MAP_NUM_MARKER;
        _key += string(_val);
      } else {
        _val = vocab[? _val];
        
        if (is_undefined(_val)) {
          exit;
        }
        
        _key += _val;
      }
      ++_i;
    }
    
    return data[$ _key];
  }
  
  /**
   * @desc Destroys the DS nested map, de-referencing any stored data structures.
   *       
   *       Any method call after this will cause the game to crash
   */
  static destroy = function() {
    if (!is_undefined(vocab) && ds_exists(vocab, ds_type_map)) {
      vocab = ds_map_destroy(vocab);
    }
    delete data;
  }
  
  /**
   * @desc Same as `destroy`, but it replaces all mehtods with `noop` functions
   */
  static destroy_soft = function() {
    static __noop = function() {};
    
    destroy(); // normal destroy
    
    // this makes it safe to call `get`/`set`
    // even after the `destroy` method was called
    self.set = __noop;
    self.get = __noop;
  }
  
}

/**
 * @func ds_nested_map_create() -> Struct.DSNestedMap
 */
function ds_nested_map_create() {
  return new DSNestedMap();
}

/**
 * @func ds_nested_map_create(_map: Struct.DSNestedMap)
 */
function ds_nested_map_destroy(_map) {
  _map.destroy();
}
