//#define _XOPEN_SOURCE 500 /* Enable certain library functions (strdup) on linux.  See feature_test_macros(7) */

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>

enum token_e{
	VAR,
	FUNC
};

enum type_e{
	Int, Char, Void
};

typedef struct value_s {
	token_e token;
	type_e type;
	char* other;
}value_s;

struct entry_s {
	char *key;
	value_s *value;
	struct entry_s *next;
};

typedef struct entry_s entry_t;

struct hashtable_s {
	int size;
	struct entry_s **table;
};

typedef struct hashtable_s hashtable_t;


/* Create a new hashtable. */
hashtable_t *ht_create( int size ) {

	hashtable_t *hashtable = NULL;
	int i;

	if( size < 1 ) return NULL;

	/* Allocate the table itself. */
	if( ( hashtable = (hashtable_t*)malloc( sizeof( hashtable_t ) ) ) == NULL ) {
		return NULL;
	}

	/* Allocate pointers to the head nodes. */
	if( ( hashtable->table = (entry_s**)malloc( sizeof( entry_t * ) * size ) ) == NULL ) {
		return NULL;
	}
	for( i = 0; i < size; i++ ) {
		hashtable->table[i] = NULL;
	}

	hashtable->size = size;

	return hashtable;
}

/* Hash a string for a particular hash table. */
int ht_hash( hashtable_t *hashtable, char *key ) {

	unsigned long int hashval=100;
	int i = 0;

	/* Convert our string to an integer */
	while( hashval < ULONG_MAX && i < strlen( key ) ) {
		hashval = hashval << 8;
		hashval += key[ i ];
		i++;
	}

	return hashval % hashtable->size;
}

/* Create a key-value pair. */
entry_t *ht_newpair( char *key, value_s *value ) {
	entry_t *newpair;

	if( ( newpair = (entry_t*)malloc( sizeof( entry_t ) ) ) == NULL ) {
		return NULL;
	}

	if( (newpair->value = (value_s*)malloc( sizeof( value_s ) ) ) == NULL){
		return NULL;
	}

	if( ( newpair->key = strdup( key ) ) == NULL ) {
		return NULL;
	}

	if( ( newpair->value->other = strdup( value->other ) ) == NULL ) {
		return NULL;
	}
	newpair->value->type = value->type;
	newpair->value->token = value->token;
	newpair->next = NULL;

	return newpair;
}

/* Insert a key-value pair into a hash table. */
void ht_set( hashtable_t *hashtable, char *key, value_s *value ) {
	int bin = 0;
	entry_t *newpair = NULL;
	entry_t *next = NULL;
	entry_t *last = NULL;

	bin = ht_hash( hashtable, key );

	next = hashtable->table[ bin ];

	while( next != NULL && next->key != NULL && strcmp( key, next->key ) > 0 ) {
		last = next;
		next = next->next;
	}

	/* There's already a pair.  Let's replace that string. */
	if( next != NULL && next->key != NULL && strcmp( key, next->key ) == 0 ) {

		free( next->value );
		next->value = (value_s*)malloc( sizeof( value_s ) );
		next->value->other = strdup(value->other);
		next->value->token = value->token;
		next->value->type = value->type;

	/* Nope, could't find it.  Time to grow a pair. */
	} else {
		newpair = ht_newpair( key, value );

		/* We're at the start of the linked list in this bin. */
		if( next == hashtable->table[ bin ] ) {
			newpair->next = next;
			hashtable->table[ bin ] = newpair;

		/* We're at the end of the linked list in this bin. */
		} else if ( next == NULL ) {
			last->next = newpair;

		/* We're in the middle of the list. */
		} else  {
			newpair->next = next;
			last->next = newpair;
		}
	}
}

/* Retrieve a key-value pair from a hash table. */
value_s* ht_get( hashtable_t *hashtable, char *key ) {
	int bin = 0;
	entry_t *pair;

	bin = ht_hash( hashtable, key );

	/* Step through the bin, looking for our value. */
	pair = hashtable->table[ bin ];
	while( pair != NULL && pair->key != NULL && strcmp( key, pair->key ) > 0 ) {
		pair = pair->next;
	}

	/* Did we actually find anything? */
	if( pair == NULL || pair->key == NULL || strcmp( key, pair->key ) != 0 ) {
		return NULL;

	} else {
		return pair->value;
	}

}

void display_table(hashtable_t* ht){
	printf("---------------------------------\n");
  printf("Symbol Table - \n");
  int i = 0;
  for(i=0;i < ht->size; i++){
    if(ht->table[i])
      printf("%d - %s : %d %d\n",i, ht->table[i]->key, ht->table[i]->value->token, ht->table[i]->value->type);
    /*else
      printf("%d - NULL\n", i);*/
  }
	printf("---------------------------------\n");
}
