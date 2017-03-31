#include<vector>
// #include "hashtable.h"
using namespace std;

/*
  sym_table provides an implementation of a symbol table.
  It consists of a stack of hashtables, defined in "hashtable.h".
  A variable scope is provided to determine current scope.
  The stack along with this variable ensures correct scope management.
*/

class sym_table{
    private:
      vector<hashtable_t*> s; //stack of hashtables
      int scope;              //stores current scope

    public:
      //enters a new scope
      void new_scope(){
        hashtable_t* ht = ht_create(50);
        s.push_back(ht);
        scope++;
      }

      //exits current scope
      void close_scope(){
        if(s.size() > 0){
          s.pop_back();
          scope--;
        }
      }

      sym_table(){
        new_scope(); //for global scope
      }

      /*
        Searches for an entry matching the key in the symbol table across all hashtables in stack.
        Refer "hashtable.h" for relevant definitions.
      */
      value_s* find_id(char* key){
        vector<hashtable_t*>::iterator it;
        value_s* get_info;
        hashtable_t* ht;

        for(it = s.end() - 1; it >= s.begin(); it--){
          ht = *it;
          get_info = ht_get(ht, key);

          if(get_info != NULL)
            break;
        }

        return get_info;
      }

      /*
        Searches symbol table for an entry matching the key.
        If not found, a new entry is added.
      */
      int save_id(char* key, value_s* value){
        hashtable_t* ht = s[s.size()-1];
        if( ht_get(ht, key) == NULL){
           ht_set(ht, key, value);
           return 1; //new id was stored
        }
        return 0; //id exists already
      }

      /*
        Searches symbol table for an entry matching the key.
        If found, entry is updated with an additional value_s
      */
      void update_id(char* key, value_s* value){
        hashtable_t* ht = s[s.size()-1];
        ht_set(ht, key, value);
      }

      //displays the entire stack of hashtables
      void display(){
        for(vector<hashtable_t*>::iterator it = s.begin(); it != s.end(); it++){
          display_table(*it);
        }
      }
};
