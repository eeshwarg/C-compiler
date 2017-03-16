#include<vector>
#include "hashtable.h"

class sym_table{
    private:
      vector<hashtable_t*> s;
      int scope;

    public:

      void new_scope(){
        hashtable_t* ht = ht_create(50);
        s.push_back(ht);
        scope++;
      }

      void close_scope(){
        if(s.size() > 0){
          s.pop_back();
          scope--;
        }
      }

      sym_table(){
        new_scope(); //for global scope
      }

      char* find_id(char* key){
        vector<hashtable_t*>::iterator it;
        char* get_info;
        hashtable_t* ht;

        for(it = s.end() - 1; it >= s.begin(); it--){
          ht = *it;
          get_info = ht_get(ht, key);

          if(get_info != NULL)
            break;
        }

        return get_info;
      }

      void save_id(char* key, char* token){
        hashtable_t* ht = s.back();
        if( ht_get(ht, key) == NULL){
          ht_set(key, token);
        }
      }
};
