export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          business_id: string | null
          branch_id: string | null
          full_name: string | null
          phone: string | null
          avatar_url: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          business_id?: string | null
          branch_id?: string | null
          full_name?: string | null
          phone?: string | null
          avatar_url?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          business_id?: string | null
          branch_id?: string | null
          full_name?: string | null
          phone?: string | null
          avatar_url?: string | null
          is_active?: boolean
          updated_at?: string
        }
      }
    }
    Views: Record<string, never>
    Functions: {
      get_user_business_id: {
        Args: Record<string, never>
        Returns: string | null
      }
      get_user_role: {
        Args: Record<string, never>
        Returns: string | null
      }
      has_permission: {
        Args: { permission_code: string }
        Returns: boolean
      }
    }
    Enums: Record<string, never>
    CompositeTypes: Record<string, never>
  }
}
